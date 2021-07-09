. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/micro:$(date +'%Y.%m.%d')-1
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

copy_repo

dnf_install "systemd procps-ng dbus-broker --nobest"

dnf_clean

rsync_rootfs

#chown -Rv root:root ${CONTAINER_PATH}/ect/pki/ca-cert/*
#find ${CONTAINER_UUID}/ -type f -exec chmod -v 0755 {} \;

#buildah run -t ${CONTAINER_UUID} update-ca-trust

buildah run -t ${CONTAINER_UUID} systemctl mask\
 console-getty.service\
 dev-hugepages.mount\
 dnf-makecache.timer\
 getty.target\
 kdump.service\
 sys-fs-fuse-connections.mount\
 systemd-homed.service\
 systemd-hostnamed.service\
 systemd-logind.service\
 systemd-machine-id-commit.service\
 systemd-random-seed.service\
 systemd-remount-fs.service\
 systemd-resolved.service\
 systemd-udev-trigger.service\
 systemd-udevd.service

buildah run -t ${CONTAINER_UUID} systemctl enable\
 dbus-broker.service

clean_files

buildah commit ${CONTAINER_UUID} ${REGISTRY}/base:$(date +'%Y.%m.%d')-1
buildah rm -a
