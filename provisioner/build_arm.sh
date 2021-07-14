#!/bin/bash

set -Eeoux pipefail

# function cleanup {
#     docker rm -f "$CONTAINER"
# }

# trap cleanup EXIT HUP INT QUIT PIPE TERM

if [[ "$CI" = false ]]; then
    EXTRA_PACKER_ARGS="-on-error=ask"
fi

if [[ "$CI" = false ]]; then
    EXTRA_DOCKER_ARGS="-it"
fi

# TODO: remove extra system packages
docker run \
       "$EXTRA_DOCKER_ARGS" \
       -w "$SETUP_DIR" \
       --rm \
       --privileged \
       --env "PKR_VAR_setup_image_dir" \
       --env "PKR_VAR_setup_provisioner_dir" \
       --env "PACKER_CACHE_DIR" \
       -v /dev:/dev \
       -v "$SETUP_DIR:$SETUP_DIR" \
       mkaczanowski/packer-builder-arm \
       build "$EXTRA_PACKER_ARGS" \
       "$SETUP_PROVISIONER_DIR/packer_arm.pkr.hcl" \
       -extra-system-packages=ansible
