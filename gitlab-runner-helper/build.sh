#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create micro ${1}

dnf_cache
dnf_install "openssh-clients git-core git-lfs hostname rsync jq unzip tar"
dnf_cache_clean
dnf_clean

GRH_VERSION=$(jq -r .[0].version ./files/versions.json)
DIN_VERSION=$(jq -r .[1].version ./files/versions.json)
if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
    curl -L -o ${CONTAINER_PATH}/usr/bin/gitlab-runner-helper $(jq -r .[0].remote_url ./files/versions.json | sed "s;VERSION;${GRH_VERSION};g")
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/dumb-init $(jq -r .[1].remote_url ./files/versions.json | sed "s;VERSION;${DIN_VERSION};g")
else
    curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -o ${CONTAINER_PATH}/usr/local/bin/gitlab-runner-helper $(jq -r .[0].local_url ./files/versions.json | sed "s;VERSION;${GRH_VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
    curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -o ${CONTAINER_PATH}/usr/local/bin/dumb-init $(jq -r .[1].local_url ./files/versions.json | sed "s;VERSION;${DIN_VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
fi
chmod -v 0755 ${CONTAINER_PATH}/usr/bin/gitlab-runner-helper
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/dumb-init

rsync_rootfs

buildah config --entrypoint='[ "/usr/local/bin/dumb-init" ]' ${CONTAINER_UUID}

container_commit gitlab-runner-helper ${IMAGE_TAG}
