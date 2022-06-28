#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

curl -L -o ${CONTAINER_PATH}/usr/local/bin/metaconvert https://github.com/grafana/mimir/releases/download/mimir-${MIMIR_VERSION}/metaconvert-linux-amd64
curl -L -o ${CONTAINER_PATH}/usr/local/bin/mimir https://github.com/grafana/mimir/releases/download/mimir-${MIMIR_VERSION}/mimir-linux-amd64
curl -L -o ${CONTAINER_PATH}/usr/local/bin/mimirtool https://github.com/grafana/mimir/releases/download/mimir-${MIMIR_VERSION}/mimirtool-linux-amd64
curl -L -o ${CONTAINER_PATH}/usr/local/bin/query-tee https://github.com/grafana/mimir/releases/download/mimir-${MIMIR_VERSION}/query-tee-linux-amd64
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{metaconvert,mimir,mimirtool,query-tee}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 mimir.service

buildah config --volume /etc/mimir ${CONTAINER_UUID}
buildah config --volume /var/lib/mimir ${CONTAINER_UUID}

container_commit mimir ${IMAGE_TAG}
