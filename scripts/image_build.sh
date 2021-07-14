#!/bin/bash

set -Eeoux pipefail

IMAGE_CONFIG_FILE="$1"
source "${IMAGE_CONFIG_FILE}"

IMAGE_INFO=$(image_info.sh "$IMAGE_CONFIG_FILE")
DISK_IMAGE_DIR=$(echo "$IMAGE_INFO" | jq -r ".relative_dir")
DISK_IMAGE_HOST_DIR=$(echo "$IMAGE_INFO" | jq -r ".absolute_dir")
DISK_IMAGE_DOCKER_PATH=$(echo "$IMAGE_INFO" | jq -r ".relative_name")

# Try to restore the directory from cache
if [[ "${CI_SEMAPHORE}" = true ]]; then
  cache restore "${DISK_IMAGE_DIR}"
fi

if [[ -d "${DISK_IMAGE_HOST_DIR}" ]]; then
  echo "Already exists, exiting: ${DISK_IMAGE_HOST_DIR}"
  exit 0
fi

IMAGE_BUILDER_NAME="${SETUP_DOCKER_REGISTRY}/${IMAGE_BUILDER_IMAGE}"

export DIB_APT_MINIMAL_CREATE_INTERFACES=0
# Force extlinux instead of grub2
IMAGE_SHA_TAG=$(git rev-parse HEAD)

if [[ "${CI}" = true ]]; then
  docker login -u mvgijssel -p "${GITHUB_DOCKER_REGISTRY_TOKEN}" docker.pkg.github.com
  EXTRA_DOCKER_ARGS=""
else
  EXTRA_DOCKER_ARGS="-it --env break=after-error"
fi

export DIB_DEV_USER_USERNAME=devuser
export DIB_DEV_USER_PWDLESS_SUDO=true
export DIB_DEV_USER_PASSWORD=devuser
export DIB_RELEASE="${DIB_RELEASE:-bionic}"
export SIZE="${SIZE:-}"

# TODO: maybe mount the global volume as read only?
# TODO: mounting the cache directory in docker volume seems to make docker crash :')
# --env DIB_IMAGE_CACHE="$SETUP_DIR/tmp/cache_image_build" \
CONTAINER=$(
  docker run \
    --rm \
    -w "$SETUP_DIR" \
    --privileged \
    $EXTRA_DOCKER_ARGS \
    -d \
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
    -v "$SETUP_DIR:$SETUP_DIR" \
    --env ELEMENTS_PATH \
    --env DIB_EXTLINUX=0 \
    --env DIB_RELEASE \
    --env DIB_APT_MINIMAL_CREATE_INTERFACES \
    --env DIB_DEV_USER_USERNAME \
    --env DIB_DEV_USER_PWDLESS_SUDO \
    --env DIB_DEV_USER_PASSWORD \
    "${IMAGE_BUILDER_NAME}:${IMAGE_SHA_TAG}"
)

function cleanup {
  docker rm -f "$CONTAINER"
}

trap cleanup EXIT HUP INT QUIT PIPE TERM

docker exec \
  $EXTRA_DOCKER_ARGS \
  $CONTAINER \
  load_env.sh disk-image-create -a "$ARCHITECTURE" -t "$FORMAT" --image-size "$SIZE" -x -o "$DISK_IMAGE_DOCKER_PATH" "$ELEMENTS"

# Store the directory in the cache
if [[ "${CI_SEMAPHORE}" = true ]]; then
  cache store "${DISK_IMAGE_DIR}" "${DISK_IMAGE_DIR}"
fi
