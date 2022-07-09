#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}


TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://github.com/syncthing/relaysrv/releases/download/v${STRELAYSRV_VERSION}/strelaysrv-linux-amd64-v${STRELAYSRV_VERSION}.tar.gz | tar xzv
popd
mv -v ${TMP_DIR}/strelaysrv-linux-amd64-v${STRELAYSRV_VERSION}/strelaysrv ${CONTAINER_PATH}/usr/local/bin/strelaysrv
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/strelaysrv
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 strelaysrv.service

buildah config --volume /etc/strelaysrv ${CONTAINER_UUID}

container_commit syncthing-relaysrv ${IMAGE_TAG}
