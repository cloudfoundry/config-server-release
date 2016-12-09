#!/bin/bash
set -e -x

install bosh-cli/bosh-cli* /usr/local/bin/bosh

cd config-server-release
pushd src/github.com/cloudfoundry/config-server
git pull origin develop
popd
bosh create-release --force --tarball=./config-server-release.tgz --name config-server --version acceptance