. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
if [ -f ./files/loki-linux-amd64.zip ] && [ -f ./files/logcli-linux-amd64.zip ]; then
    pushd ${TMP_DIR}
        unzip ./files/loki-linux-amd64.zip
        unzip ./files/logcli-linux-amd64.zip
    popd
else
    pushd ${TMP_DIR}
        curl -L -O https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip
        curl -L -O https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/logcli-linux-amd64.zip
        unzip ./loki-linux-amd64.zip
        unzip ./logcli-linux-amd64.zip
    popd
fi
mv -v ${TMP_DIR}/loki-linux-amd64 ${CONTAINER_PATH}/usr/local/bin/loki
mv -v ${TMP_DIR}/logcli-linux-amd64 ${CONTAINER_PATH}/usr/local/bin/logcli
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{loki,logcli}
rm -rvf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 loki.service

buildah config --volume /etc/loki ${CONTAINER_UUID}
buildah config --volume /var/lib/loki ${CONTAINER_UUID}

commit_container loki:latest
