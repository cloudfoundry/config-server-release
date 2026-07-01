#!/usr/bin/env bash
set -eu -o pipefail

export PATH=/usr/local/go/bin:${PATH}

cd config-server/src/github.com/cloudfoundry/config-server/

SKIP_LINT=true bin/test-unit
