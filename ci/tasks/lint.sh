#!/usr/bin/env bash
set -eu -o pipefail

cd config-server/src/config-server/

bin/lint
