#!/usr/bin/env bash
set -e

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/isc-kea-2-0.repo ${CONTAINER_PATH}/etc/yum.repos.d/isc-kea-2-0.repo
    cp -v ./files/isc-stork.repo ${CONTAINER_PATH}/etc/yum.repos.d/isc-stork.repo
fi
rpm --import --root=${CONTAINER_PATH} ./files/RPM-GPG-KEY-ISC-Kea
rpm --import --root=${CONTAINER_PATH} ./files/RPM-GPG-KEY-ISC-Stork
dnf_install "isc-kea isc-stork-agent"
dnf_cache_clean
dnf_clean

mkdir -vp ${CONTAINER_PATH}/usr/share/kea/etc
mv -v ${CONTAINER_PATH}/etc/kea/* ${CONTAINER_PATH}/usr/share/kea/etc/

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 kea-dhcp4.service
# isc-stork-agent.service

buildah config --volume /etc/kea ${CONTAINER_UUID}

container_commit kea ${IMAGE_TAG}
