#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

if [ ! -z ${FROM_IMAGE} ]; then
    if [ ${FROM_IMAGE} == "buildah" ]; then
        IMAGES="buildah buildah-zfs"
    elif [ ${FROM_IMAGE} == "podman" ]; then
        IMAGES="podman podman-zfs"
    else
        IMAGES="buildah buildah-zfs podman podman-zfs"
    fi
else
    IMAGES="buildah buildah-zfs podman podman-zfs"
fi

for IMAGE in ${IMAGES}; do
    container_create systemd ${1}

    dnf_cache
    dnf_install "openssh-clients git-core hostname"
    dnf_cache_clean
    dnf_clean

    curl -L -o ${CONTAINER_PATH}/usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/v${GITLAB_RUNNER_VERSION}/binaries/gitlab-runner-linux-amd64
    chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/gitlab-runner

    rsync_rootfs

    buildah run --network none ${CONTAINER_UUID} systemctl enable\
     gitlab-runner.service

    buildah config --volume /etc/gitlab-runner ${CONTAINER_UUID}
    buildah config --volume /var/lib/gitlab-runner ${CONTAINER_UUID}

    container_commit gitlab-runner ${IMAGE_TAG}
done
