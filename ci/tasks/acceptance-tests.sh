#!/bin/bash
set -e

echo "Installing BOSH CLI"
install bosh-cli/bosh-cli* /usr/local/bin/bosh

echo "Copying config-server bosh release"
cp bosh-release/config-server-release.tgz /tmp/config-server-release

BUILD_DIR=$PWD

pushd bosh-deployment
  echo "Deploying director..."
  start-bosh \
    -o uaa.yml \
    -o misc/config-server.yml

  if [[ $? -ne 0 ]]; then
    echo "Director failed to come up successfully"
  fi

popd
