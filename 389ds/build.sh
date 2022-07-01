#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
dnf_install "389-ds-base"
dnf_cache_clean
dnf_clean

mkdir -vp ${CONTAINER_PATH}/usr/share/dirsrv/etc
mv -v ${CONTAINER_PATH}/etc/dirsrv/* ${CONTAINER_PATH}/usr/share/dirsrv/etc/

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 dirsrv-config.service

buildah config --volume /etc/dirsrv ${CONTAINER_UUID}
buildah config --volume /var/lib/dirsrv ${CONTAINER_UUID}
buildah config --volume /var/log/dirsrv ${CONTAINER_UUID}
#/var/lock/dirsrv

container_commit 389ds ${IMAGE_TAG}
