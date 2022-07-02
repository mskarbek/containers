#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L -O https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-canary-linux-amd64.zip
    unzip ./loki-canary-linux-amd64.zip
popd
mv -v ${TMP_DIR}/loki-canary-linux-amd64 ${CONTAINER_PATH}/usr/local/bin/loki-canary
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/loki-canary

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 loki-canary.service

container_commit loki-canary ${IMAGE_TAG}
