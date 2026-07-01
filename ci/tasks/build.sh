#!/usr/bin/env bash
set -eu -o pipefail

export PATH=/usr/local/go/bin:${PATH}

binary_name="config-server-${GOOS}-${GOARCH}"

pushd config-server/src/github.com/cloudfoundry/config-server/
  go build -o "${binary_name}" .

  openssl sha256 "${binary_name}"
popd
