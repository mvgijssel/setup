#!/bin/bash

set -Eeoux pipefail

IMAGE_FILE="$1"
VAGRANT_FILE="$2"
USE_PACKER="$3"

QCOW_TO_VAGRANT_DIR="$SETUP_SCRIPTS_DIR/qcow_to_vagrant"
PROVISIONERS_DIR="$QCOW_TO_VAGRANT_DIR/provisioners"

OVF_FILE="$QCOW_TO_VAGRANT_DIR/box.ovf"
BASE_VAGRANT_FILE="$(basename $VAGRANT_FILE)"
VM_LOG_FILE="$SETUP_LOG_DIR/$BASE_VAGRANT_FILE.log"

# Create a temp dir within /tmp
TMP_DIR=$(TMPDIR=/tmp mktemp -d -t qcow_to_vagrant-XXXXXXXXXXXXX)

TMP_PACKER_OUTPUT_DIR="$TMP_DIR/packer_output"

TMP_QCOW_FILE="$TMP_DIR/image.qcow2"

VMDK_FILE="box-disk001.vmdk"
TMP_VMDK_FILE="$TMP_DIR/$VMDK_FILE"

CLOUD_INIT_FILE="box-disk002.iso"
TMP_CLOUD_INIT="$TMP_DIR/$CLOUD_INIT_FILE"

NEW_OVF_FILE="box.ovf"
TMP_OVF="$TMP_DIR/$NEW_OVF_FILE"

# Copy qcow2 file to tmp directory
cp -v $IMAGE_FILE $TMP_QCOW_FILE

# Resize the image to 32GB
qemu-img resize $TMP_QCOW_FILE 32G

# Convert the qcow2 to vmdk
qemu-img convert -f qcow2 -O vmdk $TMP_QCOW_FILE $TMP_VMDK_FILE

# Copy virtualbox export config file
cp -v $OVF_FILE $TMP_OVF

# Create cloud-init user-data
cat <<EOF | tee $TMP_DIR/user-data
#cloud-config
users:
  - name: ubuntu
    plain_text_passwd: ubuntu

    # So we can login at the console
    lock_passwd: false

    shell: /bin/bash

    # Unrestricted sudo access
    sudo: ALL=(ALL) NOPASSWD:ALL

    ssh_authorized_keys:
    - $(cat "$PUBLIC_KEY_PATH")
EOF

# Create cloud-init meta-data
cat <<EOF | tee $TMP_DIR/meta-data
# Auto-Generated - DO NOT CHANGE THIS
EOF

# Create Vagrantfile metadata
cat <<EOF | tee $TMP_DIR/metadata.json
{"provider":"virtualbox"}
EOF

# Generate cloud-init image
mkisofs \
    -output $TMP_CLOUD_INIT \
    -volid cidata \
    -joliet \
    -rock {$TMP_DIR/user-data,$TMP_DIR/meta-data}

if [[ "$CI" = false ]]; then
    EXTRA_PACKER_ARGS="-on-error=ask"
fi

if [[ "$USE_PACKER" = true ]]; then
  packer build \
    "$EXTRA_PACKER_ARGS" \
    -var "provisioners_dir=$PROVISIONERS_DIR" \
    -var "source_path=$TMP_OVF" \
    -var "output=$VAGRANT_FILE" \
    -var "output_directory=$TMP_PACKER_OUTPUT_DIR" \
    -var "cloud_init_iso=$TMP_CLOUD_INIT" \
    -var "vm_log_file=$VM_LOG_FILE" \
    -var "private_key_path=$PRIVATE_KEY_PATH" \
    -force \
    $QCOW_TO_VAGRANT_DIR/packer.json
else
    tar cvzf "${VAGRANT_FILE}" -C "${TMP_DIR}" ./metadata.json ./box.ovf ./box-disk001.vmdk ./box-disk002.iso
fi

rm -rf $TMP_DIR
