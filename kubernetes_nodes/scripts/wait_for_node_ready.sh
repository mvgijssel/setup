#!/bin/bash

set -Eeoux pipefail

NODE_NAME="$1"
STATUS_CHECK="{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}"

timeout 5m bash <<STATUS
  set -Eeou pipefail

  until kubectl get node "$NODE_NAME" -o jsonpath="$STATUS_CHECK" | grep 'Ready=True'
  do
    echo "Node '$NODE_NAME' not ready, waiting for 5 seconds."
    sleep 5
  done
STATUS
