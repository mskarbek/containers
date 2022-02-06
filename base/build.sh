. ../meta/common.sh

CONTAINER_UUID=$(create_container micro:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/{epel.repo,centos-hyperscale.repo} ${CONTAINER_PATH}/etc/yum.repos.d/
    cp -v ./files/{RPM-GPG-KEY-EPEL-8,RPM-GPG-KEY-CentOS-SIG-HyperScale} /etc/pki/rpm-gpg/
    if [ ${BASE_OS} = "c8s" ]; then
        cp -v ./files/epel-next.repo ${CONTAINER_PATH}/etc/yum.repos.d/
    fi
fi

dnf_cache
#dnf_install "systemd procps-ng dbus-broker"
dnf_install "systemd procps-ng"
dnf_clean_cache
dnf_clean

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl set-default multi-user.target
buildah run -t ${CONTAINER_UUID} systemctl mask\
 console-getty.service\
 dev-hugepages.mount\
 dnf-makecache.timer\
 getty.target\
 local-fs.target\
 remote-fs.target\
 swap.target\
 veritysetup.target\
 kdump.service\
 sys-fs-fuse-connections.mount\
 systemd-ask-password-console.path\
 systemd-ask-password-wall.path\
 systemd-homed.service\
 systemd-hostnamed.service\
 systemd-logind.service\
 systemd-machine-id-commit.service\
 systemd-random-seed.service\
 systemd-remount-fs.service\
 systemd-resolved.service\
 systemd-udev-trigger.service\
 systemd-udevd.service
#buildah run -t ${CONTAINER_UUID} systemctl enable\
# dbus-broker.service

commit_container base:latest
