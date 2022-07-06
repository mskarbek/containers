#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v${OAUTH2_PROXY_VERSION}/oauth2-proxy-v${OAUTH2_PROXY_VERSION}.linux-amd64.tar.gz|tar xzv
popd
mv -v ${TMP_DIR}/oauth2-proxy-v${OAUTH2_PROXY_VERSION}.linux-amd64/oauth2-proxy ${CONTAINER_PATH}/usr/local/bin/oauth2-proxy
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/oauth2-proxy
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 oauth2-proxy.service

buildah config --volume /etc/oauth2-proxy ${CONTAINER_UUID}

container_commit oauth2-proxy ${IMAGE_TAG}
