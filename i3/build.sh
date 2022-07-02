#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

buildah run --network none ${CONTAINER_UUID} systemctl unmask\
 systemd-logind.service

dnf_cache
dnf_install "i3 i3status xrdp xorgxrdp passwd firefox vi dmenu rxvt-unicode"
dnf_cache_clean
dnf_clean

for FILE in {remote,login,systemd-user}; do
    sed -i 's/session[ \t]*required[ \t]*pam_loginuid.so/#session    required     pam_loginuid.so/' ${CONTAINER_PATH}/etc/pam.d/${FILE}
done

rm -vf ${CONTAINER_PATH}/usr/libexec/xrdp/startwm.sh
rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl set-default\
 graphical.target

buildah run --network none ${CONTAINER_UUID} systemctl mask\
 power-profiles-daemon.service\
 upower.service

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 xrdp.service

container_commit i3 ${IMAGE_TAG}
