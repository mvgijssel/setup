#!/bin/bash

set -Eeou pipefail

GIT_SHA=$(git rev-parse HEAD)
# TODO: make sure direnv is reloaded when switching branches
IMAGE_BRANCH_TAG=$(echo "${GIT_REF}" | tr "/" _)

RESULT=$(cat <<'EOF'
{
  "sha": $sha,
  "ref": $ref,
}
EOF
)

jq -n \
   --arg sha "${GIT_SHA}" \
   --arg ref "${IMAGE_BRANCH_TAG}" \
   "$RESULT"
