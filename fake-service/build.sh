#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L -O https://github.com/nicholasjackson/fake-service/releases/download/v${FAKE_SERVICE_VERSION}/fake_service_linux_amd64.zip
    unzip ./fake_service_linux_amd64.zip
    mv -v ./fake-service ${CONTAINER_PATH}/usr/local/bin/fake-service
popd
rm -vrf ${TMP_DIR}
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/fake-service

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 fake-service.service

buildah config --volume /etc/fake-service ${CONTAINER_UUID}

container_commit fake-service ${IMAGE_TAG}
