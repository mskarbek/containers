. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
if [ -f "./files/nats-server-v${NATS_VERSION}-linux-amd64.tar.gz" ] && [ -f "./files/nats-top_${NATSTOP_VERSION}_linux_amd64.tar.gz" ] && [ -f "./files/nats-${NATSCLI_VERSION}-linux-amd64.zip" ] && [ -f "./files/nsc-linux-amd64.zip" ]; then
    pushd ${TMP_DIR}
        tar xvf ./files/nats-server-v${NATS_VERSION}-linux-amd64.tar.gz
        tar xvf ./files/nats-top_${NATSTOP_VERSION}_linux_amd64.tar.gz
        unzip ./files/nats-${NATSCLI_VERSION}-linux-amd64.zip
        unzip ./files/nsc-linux-amd64.zip
    popd
else
    pushd ${TMP_DIR}
        curl -L https://github.com/nats-io/nats-server/releases/download/v${NATS_VERSION}/nats-server-v${NATS_VERSION}-linux-amd64.tar.gz|tar xzv
        curl -L https://github.com/nats-io/nats-top/releases/download/v${NATSTOP_VERSION}/nats-top_${NATSTOP_VERSION}_linux_amd64.tar.gz|tar xzv
        curl -L -O https://github.com/nats-io/natscli/releases/download/v${NATSCLI_VERSION}/nats-${NATSCLI_VERSION}-linux-amd64.zip
        curl -L -O https://github.com/nats-io/nsc/releases/download/${NSC_VERSION}/nsc-linux-amd64.zip
        unzip ./nats-${NATSCLI_VERSION}-linux-amd64.zip
        unzip ./nsc-linux-amd64.zip
    popd
fi
mv -v ${TMP_DIR}/nats-server-v${NATS_VERSION}-linux-amd64/nats-server ${CONTAINER_PATH}/usr/local/bin/
mv -v ${TMP_DIR}/nats-top ${CONTAINER_PATH}/usr/local/bin/
mv -v ${TMP_DIR}/nats-${NATSCLI_VERSION}-linux-amd64/nats ${CONTAINER_PATH}/usr/local/bin/
mv -v ${TMP_DIR}/nsc ${CONTAINER_PATH}/usr/local/bin/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/*
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 nats.service

buildah config --volume /etc/nats ${CONTAINER_UUID}
buildah config --volume /var/lib/nats ${CONTAINER_UUID}

commit_container nats:latest
