#!/bin/bash

set -Eeou pipefail

# TODO: build more scalable way of not using variables from .envrc when they're already available
CURRENT_ELEMENTS_PATH="$ELEMENTS_PATH"

source .envrc

export ELEMENTS_PATH="$CURRENT_ELEMENTS_PATH"

exec "$@"
