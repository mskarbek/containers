#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

curl -L -o ${CONTAINER_PATH}/usr/local/bin/minio https://dl.min.io/server/minio/release/linux-amd64/archive/minio.${MINIO_VERSION}
curl -L -o ${CONTAINER_PATH}/usr/local/bin/mcli https://dl.min.io/client/mc/release/linux-amd64/archive/mc.${MCLI_VERSION}
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{minio,mcli}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 minio.service

buildah config --volume /etc/minio ${CONTAINER_UUID}
buildah config --volume /var/lib/minio ${CONTAINER_UUID}

container_commit minio ${IMAGE_TAG}
