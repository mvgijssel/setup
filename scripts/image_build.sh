#!/bin/bash

set -Eeoux pipefail

IMAGE_CONFIG_FILE="$1"
source "${IMAGE_CONFIG_FILE}"

DISK_IMAGE_NAME=$(digest.sh "${IMAGE_CONFIG_FILE}")
DISK_IMAGE_DOCKER_PATH="images/${DISK_IMAGE_NAME}"
DISK_IMAGE_HOST_PATH="${SETUP_IMAGE_DIR}/${DISK_IMAGE_NAME}.qcow2"

if [[ -f "${DISK_IMAGE_HOST_PATH}" ]]; then
  echo "Disk exists, exiting: ${DISK_IMAGE_HOST_PATH}"
  exit 0
fi

GLOBAL_ELEMENTS_DIR="${SETUP_ELEMENTS_DIR}"
IMAGE_BUILDER_NAME="${DOCKER_REGISTRY_URL}/${IMAGE_BUILDER_IMAGE}"

export DIB_RELEASE=buster
export DIB_APT_MINIMAL_CREATE_INTERFACES=0
# Force extlinux instead of grub2
export DIB_EXTLINUX=1
IMAGE_SHA_TAG=$(git rev-parse HEAD)

if [[ "${CI}" = true ]]; then
  docker login -u mvgijssel -p "${GITHUB_DOCKER_REGISTRY_TOKEN}" docker.pkg.github.com
fi

docker run \
  --rm \
  --privileged \
  -v "${SETUP_IMAGE_DIR}:/app/image" \
  -v "${LOCAL_ELEMENTS_DIR}:/app/local_elements" \
  -v "${GLOBAL_ELEMENTS_DIR}:/app/global_elements" \
  --env DIB_RELEASE \
  --env DIB_APT_MINIMAL_CREATE_INTERFACES \
  --env DIB_EXTLINUX \
  "${IMAGE_BUILDER_NAME}:${IMAGE_SHA_TAG}" \
  disk-image-create -x -o "${DISK_IMAGE_DOCKER_PATH}" "${ELEMENTS}"
