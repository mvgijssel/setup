#!/bin/bash

set -Eeoux pipefail

# Install missing lists removed by diskimage builder
sudo apt-get update

# Install dependencies for virtualbox guest additions
sudo apt-get install -y linux-headers-$(uname -r) build-essential

# Mount the disk image
mkdir -p /tmp/isomount

sudo mount -t iso9660 -o loop /dev/sr1 /tmp/isomount

# Install the drivers, the exit code of the script is unreliable so we're always returning true
# https://stackoverflow.com/questions/25434139/vboxlinuxadditions-run-never-exits-with-0
sudo /tmp/isomount/VBoxLinuxAdditions.run || true

# Check if virtualbox installation is a success
sudo /usr/sbin/VBoxService --version

if ! test -f /lib/modules/$(uname -r)/misc/vboxsf.ko
then
    echo "installation of guest additions unsuccessful"
    exit 1
fi

# Cleanup
sudo umount /tmp/isomount
