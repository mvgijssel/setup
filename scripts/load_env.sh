#!/bin/bash

set -Eeou pipefail

AFTER_VARS=
BEFORE_VARS=
BEFORE_VARS=$(compgen -v | tr '\n' ' ')

source .envrc

AFTER_VARS=$(compgen -v | tr '\n' ' ')

# diffing before and after, so we only keep the vars defined in .envrc
VARS=$(echo $BEFORE_VARS[@] $AFTER_VARS[@] | tr ' ' '\n' | sort | uniq -u)

# adding PATH to the array to force an update
VARS="$VARS PATH"

# from: https://help.github.com/en/actions/automating-your-workflow-with-github-actions/development-tools-for-github-actions#set-an-environment-variable-set-env
# setting environment variables in github actions

for var in $VARS; do
  # from: https://stackoverflow.com/a/30205555
  # if the variable $var does not exist
  if [ -z ${!var+x} ]; then
      # set an empty environment variable
      echo "::set-env name=$var::"
  else
      # set the value of $var in the env
      echo "::set-env name=$var::${!var}"
  fi
done

if [[ $GIT_REF = "refs/heads/HEAD" ]]; then
  echo "GIT_REF value is not correct: '$GIT_REF', " \
       "please check if .envrc sourcing is done correctly."

  exit 1
fi
