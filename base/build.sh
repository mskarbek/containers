#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create micro ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/epel.repo ${CONTAINER_PATH}/etc/yum.repos.d/epel.repo
    if [ ${OS_TYPE} = "c9s" ]; then
        cp -v ./files/epel-next.repo ${CONTAINER_PATH}/etc/yum.repos.d/epel-next.repo
    fi
fi
dnf_install "systemd procps-ng"
dnf_cache_clean
dnf_clean

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl set-default multi-user.target
buildah run --network none ${CONTAINER_UUID} systemctl mask\
 console-getty.service\
 dev-hugepages.mount\
 dnf-makecache.timer\
 getty.target\
 kdump.service\
 local-fs.target\
 remote-fs.target\
 swap.target\
 sys-fs-fuse-connections.mount\
 systemd-ask-password-console.path\
 systemd-ask-password-wall.path\
 systemd-homed.service\
 systemd-logind.service\
 systemd-machine-id-commit.service\
 systemd-random-seed.service\
 systemd-remount-fs.service\
 systemd-resolved.service\
 systemd-udev-trigger.service\
 systemd-udevd.service\
 veritysetup.target

rm -vf ${CONTAINER_PATH}/etc/machine-id

container_commit base ${IMAGE_TAG}
