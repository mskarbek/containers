#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://github.com/prometheus/pushgateway/releases/download/v${PUSHGATEWAY_VERSION}/pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64.tar.gz|tar xzv
popd
mv -v ${TMP_DIR}/pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64/pushgateway ${CONTAINER_PATH}/usr/local/bin/pushgateway
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/pushgateway
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 pushgateway.service

container_commit pushgateway ${IMAGE_TAG}
