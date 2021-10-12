. ../meta/functions.sh

CONTAINER_ID=$(buildah from ${REGISTRY}/systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_ID})

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
curl -L https://github.com/fleetdm/fleet/releases/download/v4.0.1/fleet_v4.0.1_linux.tar.gz|tar xzv
popd

mv -v ${TMP_DIR}/*/fleet ${CONTAINER_PATH}/usr/local/bin/

rm -rf ${TMP_DIR}

chown -v root:root ${CONTAINER_PATH}/usr/local/bin/*
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/*

rsync -hrvP --ignore-existing rootfs/ ${CONTAINER_PATH}/

buildah run -t ${CONTAINER_ID} systemctl enable\
 fleet.service

buildah commit ${CONTAINER_ID} ${REGISTRY}/fleet:latest
buildah rm -a
