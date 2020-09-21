#!/bin/bash

if [ ${DIB_DEBUG_TRACE:-1} -gt 0 ]; then
    set -x
fi
set -eu
set -o pipefail

curl -fsSL get.rebar.digital/stable -o install.sh

bash ./install.sh install

drpcli bootenvs uploadiso sledgehammer

# This makes sure that systemd output is sent to the serial port
drpcli profiles set global param kernel-console to "console=tty0 console=ttyS0,115200"

# Install Immutable Image Deployment
drpcli catalog item install image-deploy

# Install base content pack
pushd /drp/base
drpcli contents bundle base.yml
drpcli contents upload base.yml
popd

# Note we're setting the unknownBootEnv to ignore as we're pre-registering the machines in digital rebar.
drpcli prefs set defaultWorkflow discover-new unknownBootEnv ignore defaultBootEnv sledgehammer defaultStage discover