#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/redpanda.repo ${CONTAINER_PATH}/etc/yum.repos.d/redpanda.repo
fi
dnf_install "redpanda"
dnf_cache_clean
dnf_clean

buildah run --network none ${CONTAINER_UUID} rpk redpanda mode production

mkdir -vp ${CONTAINER_PATH}/usr/share/redpanda/etc
mv -v ${CONTAINER_PATH}/etc/redpanda/* ${CONTAINER_PATH}/usr/share/redpanda/etc/

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 redpanda.service

buildah config --volume /etc/redpanda ${CONTAINER_UUID}
buildah config --volume /var/lib/redpanda ${CONTAINER_UUID}

container_commit redpanda ${IMAGE_TAG}
