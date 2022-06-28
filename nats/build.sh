#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://github.com/nats-io/nats-server/releases/download/v${NATS_VERSION}/nats-server-v${NATS_VERSION}-linux-amd64.tar.gz|tar xzv
    curl -L https://github.com/nats-io/nats-top/releases/download/v${NATSTOP_VERSION}/nats-top_${NATSTOP_VERSION}_linux_amd64.tar.gz|tar xzv
    curl -L -O https://github.com/nats-io/natscli/releases/download/v${NATSCLI_VERSION}/nats-${NATSCLI_VERSION}-linux-amd64.zip
    curl -L -O https://github.com/nats-io/nsc/releases/download/${NSC_VERSION}/nsc-linux-amd64.zip
    unzip ./nats-${NATSCLI_VERSION}-linux-amd64.zip
    unzip ./nsc-linux-amd64.zip
popd
mv -v ${TMP_DIR}/nats-server-v${NATS_VERSION}-linux-amd64/nats-server ${CONTAINER_PATH}/usr/local/bin/nats-server
mv -v ${TMP_DIR}/nats-top ${CONTAINER_PATH}/usr/local/bin/nats-top
mv -v ${TMP_DIR}/nats-${NATSCLI_VERSION}-linux-amd64/nats ${CONTAINER_PATH}/usr/local/bin/nats
mv -v ${TMP_DIR}/nsc ${CONTAINER_PATH}/usr/local/bin/nsc
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{nats-server,nats-top,nats,nsc}
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 nats.service

buildah config --volume /etc/nats ${CONTAINER_UUID}
buildah config --volume /var/lib/nats ${CONTAINER_UUID}

container_commit nats ${IMAGE_TAG}
