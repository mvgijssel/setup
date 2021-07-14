#!/bin/bash

set -Eeoux pipefail

ARGS="$@"
TEMP_DIRECTORY="/tmp/digitalrebar"

mkdir -p "$SEED_DIRECTORY"
touch "$SEED_DIRECTORY/ha-state.json"

mkdir -p "$TEMP_DIRECTORY"
mv -v "$SEED_DIRECTORY/ha-state.json" "$TEMP_DIRECTORY/ha-state.json"

# Boot the server
dr-provision \
  --plugin-root="$SEED_DIRECTORY/plugins" \
  --file-root="$SEED_DIRECTORY/tftpboot" \
  --wal-root="$SEED_DIRECTORY/wal" \
  --base-root="$TEMP_DIRECTORY" &
PID=$!

# Wait for the server to be ready for a maximum of 10 seconds
timeout 10s bash <<EOF
while ! ./scripts/is_healthy.sh; do
  echo "waiting for server to boot"
  sleep 1
done
EOF

# Execute the seed while the server is running
$ARGS

# Stop the server
kill $PID

# Need to move over the ha-state.json file otherwise the server will not boot
mv -v "$TEMP_DIRECTORY/ha-state.json" "$SEED_DIRECTORY/ha-state.json"

# Remove temp directory after seeding
rm -Rv "$TEMP_DIRECTORY"
