#!/bin/bash

set -Eeoux pipefail

DNSMASQ_LEASE_FILE="$SETUP_TMP_DIR/dnsmasq.leases"
DNSMASQ_LOG_FILE="$SETUP_LOG_DIR/dnsmasq.log"
NAT_RULES_FILE="$SETUP_TMP_DIR/nat_rules"

DNS_HEAVEN_PID=$(pgrep dns-heaven || true)

if [ -z "$DNS_HEAVEN_PID" ]; then
  echo "Please make sure dns-heaven is running to make golang DNS resolution work on macos."
  echo "https://github.com/greenboxal/dns-heaven"
  exit 1
fi

CA_ROOT=$(mkcert -CAROOT)

if [[ ! -f "$CA_ROOT/rootCA.pem" ]]; then
    echo "Please generate a development root CA first with mkcert"
    echo "https://github.com/FiloSottile/mkcert"
    exit 1
fi

# NOTE: create bridge using macos network preferences one time,
# otherwise the bridge is constantly removed by macos due to some unknown process.
sudo ifconfig "$LOCAL_NETWORK_BRIDGE_INTERFACE" "$LOCAL_NETWORK_BRIDGE_IP" netmask "$LOCAL_NETWORK_NETMASK" up

# Enable packet forwarding
sudo sysctl -w net.inet.ip.forwarding=1

# Empty existing nat rules
echo "" > "$NAT_RULES_FILE"

for i in $(echo $LOCAL_NETWORK_INTERNET_INTERFACES | sed "s/,/ /g")
do

# Enable NAT forwarding from internet interface to bridge interface
cat <<EOF | tee -a "$NAT_RULES_FILE"
nat on $i from $LOCAL_NETWORK_BRIDGE_INTERFACE:network to any -> ($i)
EOF

done

# NOTE: If internet connectivity is not working inside the vm
# it's likely that the local machine network adapter connected to the internet
# is different than $LOCAL_NETWORK_INTERNET_INTERFACES.

# Flush the existing pfctl firewall rules and load the new rules
sudo pfctl -F all
sudo pfctl -f "$NAT_RULES_FILE" -e || true

# kill if exists and boot dnsmasq server on bridge interface
# matching all dns requests to *.local_network_domain to bridge ip so Vagrant doesn't crash
# and kubernetes ingress dns resolution works
kill $(cat "$LOCAL_NETWORK_DNSMASQ_PID") || true
sudo dnsmasq \
     --bind-interfaces \
     --listen-address="$LOCAL_NETWORK_BRIDGE_IP" \
     --address="/$LOCAL_NETWORK_REGISTRY_FQDN/$LOCAL_NETWORK_BRIDGE_IP" \
     --address="/$LOCAL_NETWORK_DOMAIN/$KUBERNETES_INGRESS_IP" \
     --dhcp-range="$LOCAL_NETWORK_DHCP_START,$LOCAL_NETWORK_DHCP_END,$LOCAL_NETWORK_NETMASK,12h" \
     --dhcp-leasefile="$DNSMASQ_LEASE_FILE" \
     --log-facility="$DNSMASQ_LOG_FILE" \
     --pid-file="$LOCAL_NETWORK_DNSMASQ_PID" \
     --log-dhcp \
     --log-queries \
     --domain "$LOCAL_NETWORK_DOMAIN" \
     --user="$(id -un)" \
     --group="$(id -gn)"

# create /etc/resolver entry pointing to bridge interface
cat <<EOF | sudo tee "/etc/resolver/$LOCAL_NETWORK_DOMAIN"
nameserver $LOCAL_NETWORK_BRIDGE_IP
EOF

IFS=. read ip1 ip2 ip3 ip4 <<< "$LOCAL_NETWORK_BRIDGE_IP"
# Create SSH config
cat <<EOF | sudo tee "$LOCAL_NETWORK_SSH_CONFIG_PATH"
Include ~/.ssh/config
Host *.$LOCAL_NETWORK_DOMAIN
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  User ubuntu
  IdentityFile $PRIVATE_KEY_PATH

Host $ip1.$ip2.$ip3.*
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  User ubuntu
  IdentityFile $PRIVATE_KEY_PATH
EOF

# Generate certificate
CERT_DIR="$SETUP_TMP_DIR/certs"
mkdir -p "$CERT_DIR"

REGISTRY_KEY_FILE="$LOCAL_NETWORK_REGISTRY_FQDN-key.pem"
REGISTRY_CERT_FILE="$LOCAL_NETWORK_REGISTRY_FQDN-cert.pem"

# Create a self signed certificate
mkcert \
    -key-file "$CERT_DIR/$REGISTRY_KEY_FILE" \
    -cert-file "$CERT_DIR/$REGISTRY_CERT_FILE" \
   "$LOCAL_NETWORK_REGISTRY_FQDN"

# (Re)start docker registry
# TODO: add a volume mount so we don't constantly lose all data
docker rm -f registry || true
docker run \
       -d \
       -p "$LOCAL_NETWORK_BRIDGE_IP:443:443" \
       --restart=always \
       --name registry \
       -v "$CERT_DIR:/certs" \
       -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
       -e REGISTRY_HTTP_TLS_CERTIFICATE="/certs/$REGISTRY_CERT_FILE" \
       -e REGISTRY_HTTP_TLS_KEY="/certs/$REGISTRY_KEY_FILE" \
       registry:2

# reset dns cache
dscacheutil -flushcache
sudo killall -HUP mDNSResponder
