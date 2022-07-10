#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
dnf_install "redis"
dnf_cache_clean
dnf_clean

mkdir -vp ${CONTAINER_PATH}/usr/share/redis
mv -v ${CONTAINER_PATH}/etc/redis/* ${CONTAINER_PATH}/usr/share/redis/

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 redis.service

buildah config --volume /etc/redis ${CONTAINER_UUID}
buildah config --volume /var/lib/redis ${CONTAINER_UUID}
buildah config --volume /var/log/redis ${CONTAINER_UUID}

container_commit redis ${IMAGE_TAG}
