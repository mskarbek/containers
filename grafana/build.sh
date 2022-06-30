#!/usr/bin/env bash
set -e

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/grafana.repo ${CONTAINER_PATH}/etc/yum.repos.d/grafana.repo
fi
dnf_install "grafana"
dnf_cache_clean
dnf_clean

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 grafana-server.service

buildah config --volume /etc/grafana ${CONTAINER_UUID}
buildah config --volume /var/lib/grafana ${CONTAINER_UUID}
buildah config --volume /var/log/grafana ${CONTAINER_UUID}

container_commit grafana ${IMAGE_TAG}
