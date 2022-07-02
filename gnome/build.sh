#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

buildah run --network none ${CONTAINER_UUID} systemctl unmask\
 systemd-logind.service

dnf_cache
dnf_install "gnome-shell gdm xrdp xorgxrdp passwd gnome-terminal firefox vi"
dnf_cache_clean
dnf_clean

for FILE in {remote,login,systemd-user}; do
    sed -i 's/session[ \t]*required[ \t]*pam_loginuid.so/#session    required     pam_loginuid.so/' ${CONTAINER_PATH}/etc/pam.d/${FILE}
done

#rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl set-default\
 graphical.target

buildah run --network none ${CONTAINER_UUID} systemctl mask\
 power-profiles-daemon.service\
 upower.service

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 xrdp.service

container_commit gnome ${IMAGE_TAG}
