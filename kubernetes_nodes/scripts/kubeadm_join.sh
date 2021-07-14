#!/bin/bash

set -Eeoux pipefail

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
MASTER_HOST="$1"
WORKER_HOST="$2"

JOIN_COMMAND=$(ssh -T "$MASTER_HOST" "kubeadm token create --ttl 15m --print-join-command --description 'Join $WORKER_HOST to $MASTER_HOST'")

ssh -T "$WORKER_HOST" "sudo $JOIN_COMMAND --node-name $WORKER_HOST"

"$CURRENT_DIR"/wait_for_node_ready.sh "$WORKER_HOST"
