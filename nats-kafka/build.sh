#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://github.com/nats-io/nats-kafka/releases/download/v${NATSKAFKA_VERSION}/nats-kafka-v${NATSKAFKA_VERSION}-linux-amd64.tar.gz|tar xzv
popd
mv -v ${TMP_DIR}/nats-kafka-v${NATSKAFKA_VERSION}-linux-amd64/nats-kafka ${CONTAINER_PATH}/usr/local/bin/nats-kafka
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/nats-kafka
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 nats-kafka.service

buildah config --volume /etc/nats-kafka ${CONTAINER_UUID}

container_commit nats-kafka ${IMAGE_TAG}
