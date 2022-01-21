. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
if [ -f ./files/loki-canary-linux-amd64.zip ]; then
    pushd ${TMP_DIR}
        unzip ./files/loki-canary-linux-amd64.zip
    popd
else
    pushd ${TMP_DIR}
        curl -L -O https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-canary-linux-amd64.zip
        unzip ./loki-canary-linux-amd64.zip
    popd
fi
mv -v ${TMP_DIR}/loki-canary-linux-amd64 ${CONTAINER_PATH}/usr/local/bin/loki-canary
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/loki-canary

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 loki-canary.service

commit_container loki-canary:latest
