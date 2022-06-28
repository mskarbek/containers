#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L -O https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip
    curl -L -O https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/logcli-linux-amd64.zip
    unzip ./loki-linux-amd64.zip
    unzip ./logcli-linux-amd64.zip
popd
mv -v ${TMP_DIR}/loki-linux-amd64 ${CONTAINER_PATH}/usr/local/bin/loki
mv -v ${TMP_DIR}/logcli-linux-amd64 ${CONTAINER_PATH}/usr/local/bin/logcli
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{loki,logcli}
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 loki.service

buildah config --volume /etc/loki ${CONTAINER_UUID}
buildah config --volume /var/lib/loki ${CONTAINER_UUID}

container_commit loki ${IMAGE_TAG}
