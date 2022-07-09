#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}


TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://github.com/syncthing/syncthing/releases/download/v${SYNCTHING_VERSION}/syncthing-linux-amd64-v${SYNCTHING_VERSION}.tar.gz | tar xzv
popd
mv -v ${TMP_DIR}/syncthing-linux-amd64-v${SYNCTHING_VERSION}/syncthing ${CONTAINER_PATH}/usr/local/bin/syncthing
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/syncthing
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 syncthing.service

buildah config --volume /etc/syncthing ${CONTAINER_UUID}
buildah config --volume /var/lib/syncthing ${CONTAINER_UUID}

container_commit syncthing ${IMAGE_TAG}
