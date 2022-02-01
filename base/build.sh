. ../meta/common.sh

CONTAINER_UUID=$(create_container micro:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    #cp -v ./files/centos-hyperscale.repo ${CONTAINER_PATH}/etc/yum.repos.d/centos-hyperscale.repo
    #cp -v ./files/RPM-GPG-KEY-CentOS-SIG-HyperScale /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-HyperScale
    dnf_install "systemd procps-ng"
else
    dnf_install "systemd procps-ng dbus-broker"
fi
dnf_clean_cache
dnf_clean

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl set-default multi-user.target
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

if [ -z ${IMAGE_BOOTSTRAP} ]; then
    buildah run -t ${CONTAINER_UUID} systemctl enable\
     dbus-broker.service
fi

commit_container base:latest
