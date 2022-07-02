#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
dnf_install "policycoreutils rsync tar gettext hostname bind-utils groff-base mysql-server"
dnf_cache_clean
dnf_clean

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} setcap -r /usr/libexec/mysqld
buildah run --network none ${CONTAINER_UUID} systemctl enable\
 mysqld.service

buildah config --volume /var/lib/mysql ${CONTAINER_UUID}
#buildah config --volume /var/log/mysql ${CONTAINER_UUID}

container_commit mysql8 ${IMAGE_TAG}
