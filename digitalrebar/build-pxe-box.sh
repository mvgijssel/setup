#!/bin/bash

set -Eeoux pipefail

PXE_IMAGE_DIR="$SETUP_IMAGE_DIR"
PXE_QCOW="$PXE_IMAGE_DIR/pxe.qcow2"
BOX_FILE="$SETUP_BOX_DIR/pxe.box"

mkdir -p "$PXE_IMAGE_DIR"

qemu-img create -f qcow2 "$PXE_QCOW" 32G

qcow_to_vagrant.sh "$PXE_QCOW" "$BOX_FILE" false

vagrant box remove -f "file://$BOX_FILE"
