#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
dnf_install "knot knot-module-dnstap knot-utils"
dnf_cache_clean
dnf_clean

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 knot.service

buildah config --volume /etc/knot ${CONTAINER_UUID}
buildah config --volume /var/lib/knot ${CONTAINER_UUID}

container_commit knot-dns ${IMAGE_TAG}
