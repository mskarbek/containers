. ../meta/functions.sh

CONTAINER_ID=$(buildah from ${REGISTRY}/micro:$(date +'%Y.%m.%d')-1)
CONTAINER_PATH=$(buildah mount ${CONTAINER_ID})

ln -s /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/host.repo

dnf_install "systemd procps-ng"

dnf_clean

#rsync -r --ignore-existing rootfs/ ${CONTAINER_PATH}/
rsync -hrvP --ignore-existing rootfs/ ${CONTAINER_PATH}/
#chown -Rv root:root ${CONTAINER_PATH}/ect/pki/ca-cert/*
#find ${CONTAINER_ID}/ -type f -exec chmod -v 0755 {} \;

#buildah run -t ${CONTAINER_ID} update-ca-trust

buildah run -t ${CONTAINER_ID} systemctl mask\
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

clean_files

#buildah config --cmd '[ "/usr/bin/bash" ]' ${CONTAINER_ID}

buildah commit ${CONTAINER_ID} ${REGISTRY}/base:$(date +'%Y.%m.%d')-1
buildah rm -a
