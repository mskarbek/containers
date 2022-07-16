#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

MINIO_VERSION=$(jq -r .[0].version ./files/versions.json)
MCLI_VERSION=$(jq -r .[1].version ./files/versions.json)
if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/minio $(jq -r .[0].remote_url ./files/versions.json | sed "s;VERSION;${MINIO_VERSION};g")
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/mcli $(jq -r .[1].remote_url ./files/versions.json | sed "s;VERSION;${MCLI_VERSION};g")
else
    curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -o ${CONTAINER_PATH}/usr/local/bin/minio $(jq -r .[0].local_url ./files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
    curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -o ${CONTAINER_PATH}/usr/local/bin/mcli $(jq -r .[1].local_url ./files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
fi
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{minio,mcli}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 minio.service

buildah config --volume /etc/minio ${CONTAINER_UUID}
buildah config --volume /var/lib/minio ${CONTAINER_UUID}

container_commit minio ${IMAGE_TAG}
