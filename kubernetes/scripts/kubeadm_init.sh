#!/bin/bash

set -Eeoux pipefail

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
MASTER_HOST="$1"
FLANNEL_MANIFEST="https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"

ssh "$MASTER_HOST" << SSH
  set -Eeoux pipefail

  KUBE_CONFIG_DIR="\${HOME}/.kube"
  USER_NAME="\$(id -un)"
  GROUP_NAME="\$(id -gn)"

  sudo kubeadm init \
    --control-plane-endpoint "$MASTER_HOST" \
    --pod-network-cidr=10.244.0.0/16 \
    --node-name "$MASTER_HOST" \
    --ignore-preflight-errors NumCPU \
    --skip-token-print

  sudo mkdir -p "\${KUBE_CONFIG_DIR}"
  sudo cp -v /etc/kubernetes/admin.conf "\${KUBE_CONFIG_DIR}/config"
  sudo chown -vR \$USER_NAME:\$GROUP_NAME "\${KUBE_CONFIG_DIR}"
SSH

scp -F "$SETUP_SCRIPTS_DIR/ssh_config" "$MASTER_HOST":~/.kube/config "$KUBERNETES_CONFIG_PATH"

kubectl apply -f "$FLANNEL_MANIFEST"

"$CURRENT_DIR"/wait_for_node_ready.sh "$MASTER_HOST"
