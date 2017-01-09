#!/bin/bash
set -e -x

install bosh-cli/bosh-cli* /usr/local/bin/bosh

cd config-server
CONFIG_SERVER_SHA=$(git status | head -1 | cut -d " " -f4)

cd ../config-server-release
git checkout master
git branch -u origin/master

pushd src/github.com/cloudfoundry/config-server
git checkout $CONFIG_SERVER_SHA
popd

git config --global user.email "submoduleupdate@localhost" 
git config --global user.name "CI Submodule AutoUpdate"

git add src/github.com/cloudfoundry/config-server

if [[ $(git diff-index HEAD) ]]; then
	git commit -m "Bumping config-server submodule"
fi

cd ..
cp -R config-server-release config-server-repo