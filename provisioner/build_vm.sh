#!/bin/bash

set -Eeoux pipefail

if [[ "$CI" = false ]]; then
    EXTRA_PACKER_ARGS="-on-error=ask"
fi

packer build -force $EXTRA_PACKER_ARGS packer_qemu.pkr.hcl
