#!/bin/bash

set -Eeoux pipefail

pushd "./base"

# bundle the base content pack
drpcli contents bundle base.yml

# upload the content pack
drpcli contents upload base.yml

popd

# Set default workflow
drpcli prefs set defaultWorkflow discover-new unknownBootEnv discovery