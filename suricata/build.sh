#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_copr "enable @oisf/suricata-7.0-testing"

dnf_cache
dnf_install "suricata rust cargo"
dnf_cache_clean
dnf_clean

mkdir -vp ${CONTAINER_PATH}/usr/share/suricata/etc
mv -v ${CONTAINER_PATH}/etc/suricata/* ${CONTAINER_PATH}/usr/share/suricata/etc/

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 suricata.service

buildah config --volume /etc/suricata ${CONTAINER_UUID}
buildah config --volume /var/lib/suricata ${CONTAINER_UUID}
buildah config --volume /var/log/suricata ${CONTAINER_UUID}

container_commit suricata ${IMAGE_TAG}
