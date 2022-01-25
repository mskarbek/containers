. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
if [ -f "./files/nats-kafka-v${NATSKAFKA_VERSION}-linux-amd64.tar.gz" ]; then
    tar xvf ./files/nats-kafka-v${NATSKAFKA_VERSION}-linux-amd64.tar.gz -C ${TMP_DIR}
else
    pushd ${TMP_DIR}
        curl -L https://github.com/nats-io/nats-kafka/releases/download/v${NATSKAFKA_VERSION}/nats-kafka-v${NATSKAFKA_VERSION}-linux-amd64.tar.gz|tar xzv
    popd
fi
mv -v ${TMP_DIR}/nats-kafka-v${NATSKAFKA_VERSION}-linux-amd64/nats-kafka ${CONTAINER_PATH}/usr/local/bin/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/*
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 nats-kafka.service

buildah config --volume /etc/nats-kafka ${CONTAINER_UUID}

commit_container nats-kafka:latest
