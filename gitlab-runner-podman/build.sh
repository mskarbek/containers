#!/usr/bin/env bash
set -eu

source ../meta/common.sh

for IMAGE in {"podman","podman-zfs"}; do
    container_create ${IMAGE} ${1}

    dnf_cache
    dnf_install "openssh-clients git-core hostname rsync jq unzip tar"
    dnf_cache_clean
    dnf_clean

    VERSION=$(jq -r .[0].version ./files/versions.json)
    if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
        curl -L -o ${CONTAINER_PATH}/usr/local/bin/gitlab-runner $(jq -r .[0].remote_url ./files/versions.json | sed "s;VERSION;${VERSION};g")
    else
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -o ${CONTAINER_PATH}/usr/local/bin/gitlab-runner $(jq -r .[0].local_url ./files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
    fi
    chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/gitlab-runner

    rsync_rootfs

    buildah run --network none ${CONTAINER_UUID} systemctl enable\
     gitlab-runner.service

    buildah config --volume /etc/gitlab-runner ${CONTAINER_UUID}
    buildah config --volume /var/lib/gitlab-runner ${CONTAINER_UUID}

    container_commit gitlab-runner-${IMAGE} ${IMAGE_TAG}
done
