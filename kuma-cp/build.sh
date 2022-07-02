#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://download.konghq.com/mesh-alpine/kuma-${KUMA_VERSION}-rhel-amd64.tar.gz|tar xzv
popd
mv -v ${TMP_DIR}/kuma-${KUMA_VERSION}/bin/{kuma-cp,kumactl} ${CONTAINER_PATH}/usr/local/bin/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{kuma-cp,kumactl}
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 kuma-cp.service

buildah config --volume /etc/kuma ${CONTAINER_UUID}
buildah config --volume /var/log/kuma ${CONTAINER_UUID}

container_commit kuma-cp ${IMAGE_TAG}
