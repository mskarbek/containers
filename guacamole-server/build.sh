#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

dnf_cache
dnf_install "https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm"
dnf_install "https://github.com/mskarbek/guacamole-rpm/releases/download/v1.4.0-rhel9.0/guacamole-server-1.4.0-1.el9.x86_64.rpm https://github.com/mskarbek/guacamole-rpm/releases/download/v1.4.0-rhel9.0/guacamole-server-vnc-1.4.0-1.el9.x86_64.rpm https://github.com/mskarbek/guacamole-rpm/releases/download/v1.4.0-rhel9.0/guacamole-server-rdp-1.4.0-1.el9.x86_64.rpm"
dnf_cache_clean
dnf_clean

#rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 guacd.service

buildah config --volume /etc/guacamole ${CONTAINER_UUID}

container_commit guacamole-server ${IMAGE_TAG}
