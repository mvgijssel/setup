#!/bin/bash

set -Eeoumx pipefail

# If the data directory is empty copy the seed files into it
FILES=$(ls -A "$DATA_DIRECTORY")
if [[ -z "$FILES" ]]; then
  cp -vR "$SEED_DIRECTORY"/* "$DATA_DIRECTORY"
fi

# Boot the server
dr-provision --base-root="$DATA_DIRECTORY" &
PID=$!

# Wait for the server to be ready for a maximum of 10 seconds
timeout 10s bash <<EOF
while ! ./scripts/is_healthy.sh; do
  echo "waiting for server to boot"
  sleep 1
done
EOF

# TODO: Provision the user, access keys, subnet and license

env

fg