REGISTRY='10.88.0.1:8082'

CONTAINER_ID=$(buildah from ${REGISTRY}/micro:$(date +'%Y.%m.%d')-1)
CONTAINER_PATH=$(buildah mount ${CONTAINER_ID})

ln -s /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/host.repo

dnf -y\
 --disablerepo=*\
 --enablerepo=rhel-8-for-x86_64-baseos-rpms\
 --enablerepo=rhel-8-for-x86_64-appstream-rpms\
 --installroot=${CONTAINER_PATH}\
 --releasever=8.4\
 --setopt=module_platform_id=platform:el8\
 --setopt=install_weak_deps=false\
 --nodocs\
 install systemd procps-ng
dnf -y\
 --installroot=${CONTAINER_PATH}\
 --releasever=8.4\
 clean all

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

rm -rvf\
 ${CONTAINER_PATH}/var/cache/*\
 ${CONTAINER_PATH}/var/log/dnf*\
 ${CONTAINER_PATH}/var/log/yum*\
 ${CONTAINER_PATH}/var/log/hawkey*\
 ${CONTAINER_PATH}/var/log/rhsm\
 ${CONTAINER_PATH}/etc/yum.repos.d/host.repo

#buildah config --cmd '[ "/usr/bin/bash" ]' ${CONTAINER_ID}

buildah commit ${CONTAINER_ID} ${REGISTRY}/base:$(date +'%Y.%m.%d')-1
buildah rm -a
