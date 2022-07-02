#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/influxdb.repo ${CONTAINER_PATH}/etc/yum.repos.d/influxdb.repo
fi
dnf_install "influxdb2"
dnf_cache_clean
dnf_clean

mv -v ${CONTAINER_PATH}/etc/influxdb/config.toml ${CONTAINER_PATH}/usr/share/influxdb/
rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 influxdb.service

buildah config --volume /etc/influxdb ${CONTAINER_UUID}
buildah config --volume /var/lib/influxdb ${CONTAINER_UUID}

container_commit influxdb ${IMAGE_TAG}
