#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    dnf_install "https://download.copr.fedorainfracloud.org/results/mskarbek/tinyproxy/epel-9-x86_64/04426720-tinyproxy/tinyproxy-1.11.0-1.el9.x86_64.rpm"
else
    dnf_install "tinyproxy"
fi
dnf_cache_clean
dnf_clean

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 tinyproxy.service

buildah config --volume /etc/tinyproxy ${CONTAINER_UUID}

container_commit tinyproxy ${IMAGE_TAG}
