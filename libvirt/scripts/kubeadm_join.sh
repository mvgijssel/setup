#!/bin/bash

set -Eeoux pipefail

CONTROL_PLANE_ENDPOINT="${control_plane_endpoint}"
FLANNEL_MANIFEST="https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml"
KUBE_CONFIG_DIR="${HOME}/.kube"
USER_NAME="$(id -un)"
GROUP_NAME="$(id -gn)"

echo "THE INIT COMMAND!"

# Makes this script idempotent, starting with a reset to get in a consistent state
# sudo kubeadm reset --force

# sudo kubeadm init \
#         --token "$${KUBEADM_BOOTSTRAP_TOKEN}" \
#         --token-ttl 0 \
#         --control-plane-endpoint "$${CONTROL_PLANE_ENDPOINT}" \
#         --ignore-preflight-errors NumCPU

# sudo mkdir -p "$${KUBE_CONFIG_DIR}"
# sudo cp -v /etc/kubernetes/admin.conf "$${KUBE_CONFIG_DIR}/config"
# sudo chown -vR $USER_NAME:$GROUP_NAME "$${KUBE_CONFIG_DIR}"

# kubectl apply -f "$${FLANNEL_MANIFEST}"

# STATUS_CHECK="{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}"

# timeout 5m bash <<EOF
#   set -Eeoux pipefail

#   until kubectl get node "$(hostname)" -o jsonpath="$${STATUS_CHECK}" | grep 'Ready=True'
#   do
#     echo "Not ready, sleeping for 5 seconds."
#     sleep 5
#   done
# EOF
