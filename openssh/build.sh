#!/usr/bin/env bash
set -e

source ../meta/common.sh

container_create systemd ${1}

buildah run --network none ${CONTAINER_UUID} systemctl unmask\
 systemd-logind.service

dnf_cache
dnf_install "openssh-server openssh-clients"
dnf_cache_clean
dnf_clean

for FILE in {sshd,remote,login,systemd-user}; do
    sed -i 's/session[ \t]*required[ \t]*pam_loginuid.so/#session    required     pam_loginuid.so/' ${CONTAINER_PATH}/etc/pam.d/${FILE}
done

rsync_rootfs

container_commit openssh ${IMAGE_TAG}
