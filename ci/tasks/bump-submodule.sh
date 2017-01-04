#!/bin/bash
set -e -x

install bosh-cli/bosh-cli* /usr/local/bin/bosh

cd config-server-release
git checkout develop
git branch -u origin/develop

git submodule update --remote # pull in submodule changes, branch defined in .gitmodules

git config --global user.email "submoduleupdate@localhost" 
git config --global user.name "CI Submodule AutoUpdate"

git add src/github.com/cloudfoundry/config-server

if [[ $(git diff-index HEAD) ]]; then
	git commit -m "Bumping config-server submodule"
fi

cd ..
cp -R config-server-release config-server-repo