. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
if [ -f "./files/fleet_v${FLEET_VERSION}_linux.tar.gz" ] && [ -f "./files/fleetctl_v${FLEET_VERSION}_linux.tar.gz" ]; then
    tar xvf ./files/fleet_v${FLEET_VERSION}_linux.tar.gz -C ${TMP_DIR}
    tar xvf ./files/fleetctl_v${FLEET_VERSION}_linux.tar.gz -C ${TMP_DIR}
else
    pushd ${TMP_DIR}
        curl -L https://github.com/fleetdm/fleet/releases/download/fleet-v${FLEET_VERSION}/fleet_v${FLEET_VERSION}_linux.tar.gz|tar xzv
        curl -L https://github.com/fleetdm/fleet/releases/download/fleet-v${FLEET_VERSION}/fleetctl_v${FLEET_VERSION}_linux.tar.gz|tar xzv
    popd
fi
mv -v ${TMP_DIR}/fleet_v${FLEET_VERSION}_linux/fleet ${CONTAINER_PATH}/usr/local/bin/
mv -v ${TMP_DIR}/fleetctl_v${FLEET_VERSION}_linux/fleetctl ${CONTAINER_PATH}/usr/local/bin/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{fleet,fleetctl}
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 fleet.service

#buildah config --volume /etc/kuma ${CONTAINER_UUID}
#buildah config --volume /var/log/kuma ${CONTAINER_UUID}

commit_container fleet:latest
