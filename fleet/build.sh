#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://github.com/fleetdm/fleet/releases/download/fleet-v${FLEET_VERSION}/fleet_v${FLEET_VERSION}_linux.tar.gz|tar xzv
    curl -L https://github.com/fleetdm/fleet/releases/download/fleet-v${FLEET_VERSION}/fleetctl_v${FLEET_VERSION}_linux.tar.gz|tar xzv
popd
mv -v ${TMP_DIR}/fleet_v${FLEET_VERSION}_linux/fleet ${CONTAINER_PATH}/usr/local/bin/fleet
mv -v ${TMP_DIR}/fleetctl_v${FLEET_VERSION}_linux/fleetctl ${CONTAINER_PATH}/usr/local/bin/fleetctl
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{fleet,fleetctl}
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 fleet.service

#buildah config --volume /etc/kuma ${CONTAINER_UUID}
#buildah config --volume /var/log/kuma ${CONTAINER_UUID}

container_commit fleet ${IMAGE_TAG}
