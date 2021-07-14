#!/bin/bash


set -Eeoux pipefail

sudo rm -fv /var/log/cloud-init-output.log /var/log/cloud-init.log /etc/network/interfaces.d/50-cloud-init.cfg /etc/resolv.conf

# clean the cloud-init user-data, so when booting a new instance with cloud-init
# the cloud-init changes will be applied
sudo cloud-init clean
