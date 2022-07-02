#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
dnf_install "nginx nginx-mod-stream"
dnf_cache_clean
dnf_clean

rm -vf ${CONTAINER_PATH}/etc/nginx/nginx.conf
rm -vf ${CONTAINER_PATH}/usr/share/nginx/html/index.html
touch ${CONTAINER_PATH}/usr/share/nginx/html/index.html

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 etc-nginx-conf.d.path\
 etc-nginx-stream.d.path\
 nginx.service

buildah config --volume /etc/nginx/conf.d ${CONTAINER_UUID}
buildah config --volume /etc/nginx/stream.d ${CONTAINER_UUID}
buildah config --volume /etc/pki/tls/private ${CONTAINER_UUID}
buildah config --volume /var/log/nginx ${CONTAINER_UUID}

container_commit nginx ${IMAGE_TAG}
