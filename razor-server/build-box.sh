#!/bin/bash

set -Eeoux pipefail

qcow_to_vagrant.sh "${SETUP_RAZOR_SERVER_DIR}/images/razor-server/razor-server_buster.qcow2" "${SETUP_RAZOR_SERVER_DIR}/razor-server.box" true
