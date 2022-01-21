. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
if [ -f "./files/pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64.tar.gz" ]; then
    tar xvf ./files/pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64.tar.gz -C ${TMP_DIR}
else
    pushd ${TMP_DIR}
        curl -L https://github.com/prometheus/pushgateway/releases/download/v${PUSHGATEWAY_VERSION}/pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64.tar.gz|tar xzv
    popd
fi
mv -v ${TMP_DIR}/pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64/pushgateway ${CONTAINER_PATH}/usr/local/bin/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/*
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 pushgateway.service

commit_container pushgateway:latest
