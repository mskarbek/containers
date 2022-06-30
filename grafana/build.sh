#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

dnf_cache
dnf_install "findutils"
dnf_install "https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}-1.x86_64.rpm"
dnf_cache_clean
dnf_clean

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 grafana-server.service

buildah config --volume /etc/grafana ${CONTAINER_UUID}
buildah config --volume /var/lib/grafana ${CONTAINER_UUID}
buildah config --volume /var/log/grafana ${CONTAINER_UUID}

container_commit grafana ${IMAGE_TAG}
