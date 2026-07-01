#!/usr/bin/env bash
set -eu -o pipefail

cd config-server
bundle install
bundle exec rspec
