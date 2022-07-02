#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
dnf_install "vsftpd passwd"
dnf_cache_clean
dnf_clean

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 vsftpd.service

container_commit vsftpd ${IMAGE_TAG}
