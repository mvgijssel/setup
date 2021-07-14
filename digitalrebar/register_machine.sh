#!/bin/bash

set -Eeoux pipefail

export MACHINE_NAME="$1"
MACHINE_MAC="$2"

MACHINE_CONFIG=$(cat <<EOF
Available: true
Name: $MACHINE_NAME
Pool: base
PoolAllocated: false
PoolStatus: Free
HardwareAddrs:
  - '$MACHINE_MAC'
EOF
)


MACHINE_ID=$(drpcli machines list | jq -r 'map(select(.Name == env.MACHINE_NAME)) | first .Uuid')

if [ "$MACHINE_ID" != "null" ]; then
  drpcli machines destroy "$MACHINE_ID"
fi

drpcli machines create "$MACHINE_CONFIG"

