#!/bin/bash
set -e

echo "Installing BOSH CLI"
install bosh-cli/bosh-cli* /usr/local/bin/bosh

echo "Copying config-server bosh release"
cp bosh-release/config-server-release.tgz /tmp/config-server-release

pushd bosh-deployment

echo "Setting up ruby"
source /etc/profile.d/chruby.sh
chruby "2.3.1"

# v263.1
echo "Downloading compiled bosh release"
wget "https://s3.amazonaws.com/config-server-acceptance-test-dependencies/bosh-263.1.0-ubuntu-trusty-3445.7-compiled-release.tgz" -O /tmp/compiled_bosh_release

echo "Writing private key"
printenv private_key > private_key.pem

echo "Deploying director..."
bosh create-env ./bosh.yml \
  -o ./aws/cpi.yml \
  -o uaa.yml \
  -o external-ip-with-registry-not-recommended.yml \
  -o external-ip-not-recommended-uaa.yml \
  -o jumpbox-user.yml \
  -o config-server.yml \
  -o ../config-server-release/ci/tasks/compiled_releases.yml \
  --state ./state.json \
  --vars-store ./creds.yml \
  -v director_name=bosh \
  -v external_ip=${external_ip} \
  -v internal_cidr=${internal_cidr} \
  -v internal_gw=${internal_gw} \
  -v internal_ip=${internal_ip} \
  -v region=${region} \
  -v az=${az} \
  -v default_key_name=${default_key_name} \
  -v default_security_groups=${default_security_groups} \
  -v subnet_id=${subnet_id} \
  -v access_key_id=${access_key_id} \
  -v secret_access_key=${secret_access_key} \
  --var-file private_key=./private_key.pem

if [[ $? -eq 0 ]]; then 
  echo "Deleting director"
  bosh delete-env ./bosh.yml \
    -o ./aws/cpi.yml \
    -o uaa.yml \
    -o external-ip-with-registry-not-recommended.yml \
    -o external-ip-not-recommended-uaa.yml \
    -o jumpbox-user.yml \
    -o config-server.yml \
    -o ../config-server-release/ci/tasks/compiled_releases.yml \
    --state ./state.json \
    --vars-store ./creds.yml \
    -v director_name=bosh \
    -v external_ip=${external_ip} \
    -v internal_cidr=${internal_cidr} \
    -v internal_gw=${internal_gw} \
    -v internal_ip=${internal_ip} \
    -v region=${region} \
    -v az=${az} \
    -v default_key_name=${default_key_name} \
    -v default_security_groups=${default_security_groups} \
    -v subnet_id=${subnet_id} \
    -v access_key_id=${access_key_id} \
    -v secret_access_key=${secret_access_key} \
    --var-file private_key=./private_key.pem
else
  echo "Director failed to come up successfully"
fi

popd
