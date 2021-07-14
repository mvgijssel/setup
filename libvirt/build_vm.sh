#!/bin/bash

set -Eeoux pipefail

if [[ "$CI" = false ]]; then
    EXTRA_PACKER_ARGS="-on-error=ask"
fi

# docker run "$EXTRA_DOCKER_ARGS" --rm --privileged -v /dev:/dev -v "$SETUP_PROVISIONER_DIR":/build mkaczanowski/packer-builder-arm build "$EXTRA_PACKER_ARGS" packer.json

packer build -force $EXTRA_PACKER_ARGS packer_qemu.pkr.hcl
