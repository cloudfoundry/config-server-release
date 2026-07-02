#!/bin/bash
set -e -x

install bosh-cli/bosh-cli* /usr/local/bin/bosh

cd config-server
config_server_sha=$(git rev-parse --verify HEAD)
cd -


cd config-server
git submodule update --init --recursive

cd src/config-server
git checkout "${config_server_sha}"
cd -

bosh create-release --force --tarball=./config-server-release.tgz --name config-server --version acceptance

cp ./config-server-release.tgz ../bosh-release/config-server-release.tgz
