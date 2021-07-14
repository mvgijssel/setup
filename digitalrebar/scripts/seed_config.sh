#!/bin/bash

set -Eeoux pipefail

# Install required community content
drpcli catalog item install drp-community-content

# Upload sledgehammer iso
drpcli bootenvs uploadiso sledgehammer

# Remove unnecessary sledgehammer files
rm -vR "$SEED_DIRECTORY/tftpboot/sledgehammer/arm64"
rm -vR "$SEED_DIRECTORY/tftpboot/sledgehammer/rpi4"
rm -v "$SEED_DIRECTORY"/tftpboot/isos/sledgehammer-*.arm64.tar
rm -v "$SEED_DIRECTORY"/tftpboot/isos/sledgehammer-*.rpi4.tar

# Upload default content
drpcli contents upload catalog:task-library-stable

# Ensure logs are forwarded to console port
drpcli profiles set global param kernel-console to "console=tty0 console=ttyS0,115200"

# Install image deploy content pack
drpcli catalog item install image-deploy