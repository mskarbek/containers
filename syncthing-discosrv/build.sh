#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}


TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://github.com/syncthing/discosrv/releases/download/v${STDISCOSRV_VERSION}/stdiscosrv-linux-amd64-v${STDISCOSRV_VERSION}.tar.gz | tar xzv
popd
mv -v ${TMP_DIR}/stdiscosrv-linux-amd64-v${STDISCOSRV_VERSION}/stdiscosrv ${CONTAINER_PATH}/usr/local/bin/stdiscosrv
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/stdiscosrv
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 stdiscosrv.service

buildah config --volume /etc/stdiscosrv ${CONTAINER_UUID}
buildah config --volume /var/lib/stdiscosrv ${CONTAINER_UUID}

container_commit syncthing-discosrv ${IMAGE_TAG}
