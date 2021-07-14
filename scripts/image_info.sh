#!/bin/bash

set -Eeou pipefail

IMAGE_CONFIG_FILE="$1"
source "${IMAGE_CONFIG_FILE}"

DIGEST=$(digest.sh "$IMAGE_CONFIG_FILE")
DIGEST_FOLDER="$IMAGE_NAME-$DIGEST"
IMAGE_FILE_TGZ="$IMAGE_NAME.tgz"
IMAGE_FILE_QCOW="$IMAGE_NAME.qcow2"
IMAGE_FILE_BOX="$IMAGE_NAME.box"
ABSOLUTE_DIR="$SETUP_IMAGE_DIR/$DIGEST_FOLDER"
ABSOLUTE_NAME="$ABSOLUTE_DIR/$IMAGE_NAME"
ABSOLUTE_PATH_TGZ="$ABSOLUTE_DIR/$IMAGE_FILE_TGZ"
ABSOLUTE_PATH_QCOW="$ABSOLUTE_DIR/$IMAGE_FILE_QCOW"
ABSOLUTE_PATH_BOX="$SETUP_BOX_DIR/$IMAGE_FILE_BOX"
RELATIVE_IMAGE_DIR=$(realpath --relative-to=$SETUP_DIR $SETUP_IMAGE_DIR)
RELATIVE_BOX_DIR=$(realpath --relative-to=$SETUP_DIR $SETUP_BOX_DIR)
RELATIVE_DIR="$RELATIVE_IMAGE_DIR/$DIGEST_FOLDER"
RELATIVE_PATH_TGZ="$RELATIVE_DIR/$IMAGE_FILE_TGZ"
RELATIVE_PATH_QCOW="$RELATIVE_DIR/$IMAGE_FILE_QCOW"
RELATIVE_PATH_BOX="$RELATIVE_BOX_DIR/$IMAGE_FILE_BOX"
RELATIVE_NAME="$RELATIVE_DIR/$IMAGE_NAME"

RESULT=$(cat <<'EOF'
{
  "digest": $digest,
  "absolute_path_tgz": $absolute_path_tgz,
  "absolute_path_qcow": $absolute_path_qcow,
  "absolute_path_box": $absolute_path_box,
  "absolute_dir": $absolute_dir,
  "absolute_name": $absolute_name,
  "relative_path_tgz": $relative_path_tgz,
  "relative_path_qcow": $relative_path_qcow,
  "relative_path_box": $relative_path_box,
  "relative_dir": $relative_dir,
  "relative_name": $relative_name,
  "image_name": $image_name,
  "image_file_tgz": $image_file_tgz,
  "image_file_qcow": $image_file_qcow,
  "image_file_box": $image_file_box
}
EOF
)

jq -n \
   --arg digest "${DIGEST}" \
   --arg absolute_path_tgz "${ABSOLUTE_PATH_TGZ}" \
   --arg absolute_path_qcow "${ABSOLUTE_PATH_QCOW}" \
   --arg absolute_path_box "${ABSOLUTE_PATH_BOX}" \
   --arg absolute_dir "${ABSOLUTE_DIR}" \
   --arg absolute_name "${ABSOLUTE_NAME}" \
   --arg relative_path_tgz "${RELATIVE_PATH_TGZ}" \
   --arg relative_path_qcow "${RELATIVE_PATH_QCOW}" \
   --arg relative_path_box "${RELATIVE_PATH_BOX}" \
   --arg relative_dir "${RELATIVE_DIR}" \
   --arg relative_name "${RELATIVE_NAME}" \
   --arg image_name "${IMAGE_NAME}" \
   --arg image_file_tgz "${IMAGE_FILE_TGZ}" \
   --arg image_file_qcow "${IMAGE_FILE_QCOW}" \
   --arg image_file_box "${IMAGE_FILE_BOX}" \
   "$RESULT"
