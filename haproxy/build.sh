#!/usr/bin/env bash
set -e

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
dnf_install "haproxy"
dnf_cache_clean
dnf_clean

mv -v ${CONTAINER_PATH}/etc/haproxy/haproxy.cfg ${CONTAINER_PATH}/usr/share/haproxy/haproxy.cfg

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 haproxy.service

buildah config --volume /etc/haproxy ${CONTAINER_UUID}

container_commit haproxy ${IMAGE_TAG}
