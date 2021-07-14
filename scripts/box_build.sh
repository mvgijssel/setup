#!/bin/bash

set -Eeoux pipefail

IMAGE_CONFIG_FILE="$1"
source "$IMAGE_CONFIG_FILE"

IMAGE_INFO=$(image_info.sh "$IMAGE_CONFIG_FILE")
DISK_FILE=$(echo "$IMAGE_INFO" | jq -r .absolute_path_qcow)
BOX_FILE=$(echo "$IMAGE_INFO" | jq -r .absolute_path_box)

qcow_to_vagrant.sh "$DISK_FILE" "$BOX_FILE" "$VAGRANT_BOX_USE_PACKER"
