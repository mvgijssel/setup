#!/bin/bash

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/ for what this `set` means
set -Eeoux pipefail

IMAGE_NAME="$1"
IMAGE_DIRECTORY="$2"
shift 2
EXTRA_ARGS="$@"
FULL_IMAGE_NAME="${SETUP_DOCKER_REGISTRY}/${IMAGE_NAME}"

GIT_SHA=$(git rev-parse HEAD)
IMAGE_BRANCH_TAG=$(echo "${GIT_REF}" | tr "/" _)
IMAGE_SHA_TAG="${GIT_SHA}"

if [[ "${CI}" = true ]]; then
  docker login -u mvgijssel -p "${GITHUB_DOCKER_REGISTRY_TOKEN}" docker.pkg.github.com
fi

docker pull "${FULL_IMAGE_NAME}:latest" || true
docker pull "${FULL_IMAGE_NAME}:${IMAGE_BRANCH_TAG}" || true

docker build \
  --cache-from "${FULL_IMAGE_NAME}:latest" \
  --cache-from "${FULL_IMAGE_NAME}:${IMAGE_BRANCH_TAG}" \
  --build-arg IMAGE_SHA_TAG="${IMAGE_SHA_TAG}" \
  --build-arg DOCKER_REGISTRY="${SETUP_DOCKER_REGISTRY}" \
  --tag "${FULL_IMAGE_NAME}:${IMAGE_BRANCH_TAG}" \
  --tag "${FULL_IMAGE_NAME}:${IMAGE_SHA_TAG}" \
  $EXTRA_ARGS \
  "${IMAGE_DIRECTORY}"

docker push "${FULL_IMAGE_NAME}:${IMAGE_BRANCH_TAG}"
docker push "${FULL_IMAGE_NAME}:${IMAGE_SHA_TAG}"
