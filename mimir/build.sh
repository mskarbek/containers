#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

VERSION=$(jq -r .[0].version ./files/versions.json)
if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/metaconvert $(jq -r .[0].remote_url ./files/versions.json | sed "s;VERSION;${VERSION};g")
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/mimir $(jq -r .[1].remote_url ./files/versions.json | sed "s;VERSION;${VERSION};g")
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/mimirtool $(jq -r .[2].remote_url ./files/versions.json | sed "s;VERSION;${VERSION};g")
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/query-tee $(jq -r .[3].remote_url ./files/versions.json | sed "s;VERSION;${VERSION};g")
else
    curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -o ${CONTAINER_PATH}/usr/local/bin/metaconvert $(jq -r .[0].local_url ./files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
    curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -o ${CONTAINER_PATH}/usr/local/bin/mimir $(jq -r .[1].local_url ./files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
    curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -o ${CONTAINER_PATH}/usr/local/bin/mimirtool $(jq -r .[2].local_url ./files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
    curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -o ${CONTAINER_PATH}/usr/local/bin/query-tee $(jq -r .[3].local_url ./files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
fi
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{metaconvert,mimir,mimirtool,query-tee}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 mimir.service

buildah config --volume /etc/mimir ${CONTAINER_UUID}
buildah config --volume /var/lib/mimir ${CONTAINER_UUID}

container_commit mimir ${IMAGE_TAG}
