#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

curl -L -o ${CONTAINER_PATH}/usr/local/bin/minio-console https://github.com/minio/console/releases/download/v${MINIO_CONSOLE_VERSION}/console-linux-amd64
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/minio-console

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 minio-console.service

buildah config --volume /etc/minio-console ${CONTAINER_UUID}

container_commit minio-console ${IMAGE_TAG}
