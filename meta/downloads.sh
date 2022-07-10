#!/usr/bin/env bash
set -eu

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -s -L -O https://github.com/fleetdm/fleet/releases/download/fleet-v4.17.0/fleet_v4.17.0_linux.tar.gz
    curl -s -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" --upload-file fleet_v4.17.0_linux.tar.gz ${REPOSITORY_URL}/repository/raw-hosted-prd/f/fleet/4.17.0/fleet_v4.17.0_linux.tar.gz

    curl -s -L -O https://github.com/fleetdm/fleet/releases/download/fleet-v4.17.0/fleetctl_v4.17.0_linux.tar.gz
    curl -s -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" --upload-file fleetctl_v4.17.0_linux.tar.gz ${REPOSITORY_URL}/repository/raw-hosted-prd/f/fleetctl/4.17.0/fleetctl_v4.17.0_linux.tar.gz
popd
rm -rf ${TMP_DIR}
