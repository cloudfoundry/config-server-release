#!/usr/bin/env bash
set -eu -o pipefail

cd config-server/src/github.com/cloudfoundry/config-server/

bin/lint
