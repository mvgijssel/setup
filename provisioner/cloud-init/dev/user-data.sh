#!/bin/bash

set -Eeou pipefail

CERT=$(cat "$(mkcert -CAROOT)/rootCA.pem")
jinja2 --strict -D root_ca="$CERT" "$SETUP_PROVISIONER_DIR/cloud-init/dev/user-data.j2"
