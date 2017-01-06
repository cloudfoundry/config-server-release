#!/bin/sh
set -e -x

install bosh-cli/bosh-cli* /usr/local/bin/bosh

cd config-server-release
git submodule update --remote # pull in submodule changes, branch defined in .gitmodules

bosh create-release --force --tarball=./config-server-release.tgz --name config-server --version acceptance