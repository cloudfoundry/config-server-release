#!/bin/bash
set -e -x

install bosh-cli/bosh-cli* /usr/local/bin/bosh

cd config-server-release

rm -rf src/github.com/cloudfoundry/config-server
ln -s ../../../../config-server src/github.com/cloudfoundry/config-server

bosh create-release --force --tarball=./config-server-release.tgz --name config-server --version acceptance

cp ./config-server-release.tgz ../bosh-release/config-server-release.tgz
