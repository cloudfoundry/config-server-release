#!/usr/bin/env bash
set -eu -o pipefail

RELEASE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)/config-server"

if [[ -n "${DEBUG:-}" ]]; then
  set -x
  export BOSH_LOG_LEVEL=debug
fi

echo "Starting BOSH Director"
source start-bosh
source /tmp/local-bosh/director/bosh-env

echo "Uploading stemcell"
bosh -n upload-stemcell stemcell/*.tgz

echo "Uploading BPM release"
bosh -n upload-release /usr/local/releases/bpm.tgz

echo "Creating and uploading config-server release"
bosh create-release --dir "${RELEASE_PATH}"
bosh upload-release --dir "${RELEASE_PATH}"

echo "Deploying config-server"
bosh -n -d config-server-test deploy \
  --var=stemcell_os="${STEMCELL_OS}" \
  --vars-store=/tmp/config-server-test-creds.yml \
  "${RELEASE_PATH}/manifests/test.yml"

echo "Deployment complete. Instances:"
bosh -d config-server-test instances --details

CS_IP="$(bosh -d config-server-test instances | grep running | awk '{ print $4 }')"
echo "config-server IP: ${CS_IP}"

echo "Verifying config-server API responds..."
response_code="$(curl -sk -o /dev/null -w "%{http_code}" "https://${CS_IP}:8080/v1/data?name=test-key")"

if [[ "${response_code}" == "401" ]]; then
  echo "SUCCESS: config-server is responding correctly (received expected 401 Unauthorized)"
else
  echo "ERROR: Expected HTTP 401 from config-server, got HTTP ${response_code}"
  exit 1
fi
