#!/bin/bash

set -Eeoux pipefail

export GO111MODULE=on
export GOFLAGS=-mod=vendor
export LDFLAGS="-w"

TERRAFORM_LIBVIRT_DIR="$SETUP_TMP_DIR/terraform-provider-libvirt"

if [ -d "$TERRAFORM_LIBVIRT_DIR" ]; then
  pushd "$TERRAFORM_LIBVIRT_DIR"
  git pull
  popd
else
  git clone https://github.com/dmacvicar/terraform-provider-libvirt.git "$TERRAFORM_LIBVIRT_DIR"
fi

pushd "$TERRAFORM_LIBVIRT_DIR"
  make install
popd

PLUGIN_LIBVIRT_DIR="${HOME}/.terraform.d/plugins/local/setup/libvirt/0.0.1/darwin_amd64"
PLUGIN_LIBVIRT_NAME="terraform-provider-libvirt_v0.0.1"
mkdir -p $PLUGIN_LIBVIRT_DIR

cp -v $GOPATH/bin/terraform-provider-libvirt $PLUGIN_LIBVIRT_DIR/$PLUGIN_LIBVIRT_NAME

PLUGIN_KUSTOMIZE_DIR="${HOME}/.terraform.d/plugins/local/setup/kustomization/0.0.1/darwin_amd64"
mkdir -p $PLUGIN_KUSTOMIZE_DIR
KUSTOMIZE_TAR="$SETUP_TMP_DIR"/terraform-provider-kustomization.tar.gz

wget -O "$KUSTOMIZE_TAR" https://github.com/kbst/terraform-provider-kustomize/releases/download/v0.2.0-beta.0/terraform-provider-kustomization-darwin-amd64_v0.2.0-beta.0.tgz

tar -C "${PLUGIN_KUSTOMIZE_DIR}" --strip-components=3 -xf "$KUSTOMIZE_TAR"
