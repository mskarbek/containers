#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
dnf_install "knot-resolver knot-resolver-module-dnstap knot-resolver-module-http"
dnf_cache_clean
dnf_clean

mkdir -vp ${CONTAINER_PATH}/usr/share/knot-resolver
mv -v ${CONTAINER_PATH}/etc/knot-resolver/* ${CONTAINER_PATH}/usr/share/knot-resolver/
rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 kres-cache-gc.service\
 kresd@1.service

buildah config --volume /etc/knot-resolver ${CONTAINER_UUID}

container_commit knot-resolver ${IMAGE_TAG}
