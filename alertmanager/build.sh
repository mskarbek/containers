#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz|tar xzv
popd
mv -v ${TMP_DIR}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/{alertmanager,amtool} ${CONTAINER_PATH}/usr/local/bin/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{alertmanager,amtool}
mkdir -vp ${CONTAINER_PATH}/usr/share/alertmanager
mv -v ${TMP_DIR}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/alertmanager.yml ${CONTAINER_PATH}/usr/share/alertmanager/alertmanager.yml
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 alertmanager.service

buildah config --volume /etc/alertmanager ${CONTAINER_UUID}
buildah config --volume /var/lib/alertmanager ${CONTAINER_UUID}

container_commit alertmanager ${IMAGE_TAG}
