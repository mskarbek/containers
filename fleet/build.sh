#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
        curl -L https://github.com/fleetdm/fleet/releases/download/fleet-v${FLEET_VERSION}/fleet_v${FLEET_VERSION}_linux.tar.gz | tar xzv
        curl -L https://github.com/fleetdm/fleet/releases/download/fleet-v${FLEETCTL_VERSION}/fleetctl_v${FLEETCTL_VERSION}_linux.tar.gz | tar xzv
    else
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L ${REPOSITORY_URL}/repository/raw-hosted-prd/f/fleet/${FLEET_VERSION}/fleet_v${FLEET_VERSION}_linux.tar.gz | tar xzv
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L ${REPOSITORY_URL}/repository/raw-hosted-prd/f/fleetctl/${FLEETCTL_VERSION}/fleetctl_v${FLEETCTL_VERSION}_linux.tar.gz | tar xzv
    fi
popd
mv -v ${TMP_DIR}/fleet_v${FLEET_VERSION}_linux/fleet ${CONTAINER_PATH}/usr/local/bin/fleet
mv -v ${TMP_DIR}/fleetctl_v${FLEET_VERSION}_linux/fleetctl ${CONTAINER_PATH}/usr/local/bin/fleetctl
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{fleet,fleetctl}
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 fleet.service

buildah config --volume /etc/fleet ${CONTAINER_UUID}
buildah config --volume /var/log/fleet ${CONTAINER_UUID}

container_commit fleet ${IMAGE_TAG}
