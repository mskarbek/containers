. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} registry.access.redhat.com/ubi8/ubi:8.4
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

ZFS_VERSION="2.1.0"

cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
rm ${CONTAINER_PATH}/etc/yum.repos.d/ubi.repo

dnf -y\
 --installroot=${CONTAINER_PATH}\
 --releasever=8\
 --setopt=module_platform_id=platform:el8\
 --setopt=install_weak_deps=false\
 --nodocs\
 update

cat << EOF > ${CONTAINER_PATH}/etc/yum.repos.d/hyperscale.repo
[proxy-hyperscale]
name=CentOS 8 Stream - Hyperscale
baseurl=http://mirror.centos.org/centos/8-stream/hyperscale/x86_64/packages-main/
enabled=1
gpgcheck=0

[proxy-facebook]
name=CentOS 8 Stream - Hyperscale Facebook
baseurl=http://mirror.centos.org/centos/8-stream/hyperscale/x86_64/packages-facebook/
enabled=1
gpgcheck=0
EOF

dnf -y\
 --installroot=${CONTAINER_PATH} \
 --enablerepo=codeready-builder-for-rhel-8-x86_64-rpms\
 --releasever=8\
 --setopt=module_platform_id=platform:el8\
 --setopt=install_weak_deps=false\
 --nodocs\
 install\
 https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

dnf -y\
 --installroot=${CONTAINER_PATH} \
 --enablerepo=codeready-builder-for-rhel-8-x86_64-rpms\
 --releasever=8\
 --setopt=module_platform_id=platform:el8\
 --setopt=install_weak_deps=false\
 --nodocs\
 install\
 dbus-broker\
 procps-ng\
 systemd\
 buildah\
 git-core\
 rsync\
 openssh-server\
 openssh-clients\
 ./zfs/libnvpair3-${ZFS_VERSION}-1.el8.x86_64.rpm\
 ./zfs/libuutil3-${ZFS_VERSION}-1.el8.x86_64.rpm\
 ./zfs/libzfs5-${ZFS_VERSION}-1.el8.x86_64.rpm\
 ./zfs/libzpool5-${ZFS_VERSION}-1.el8.x86_64.rpm\
 ./zfs/zfs-${ZFS_VERSION}-1.el8.x86_64.rpm\
 ./zfs/zfs-kmod-${ZFS_VERSION}-1.dummy.el8.x86_64.rpm

dnf -y\
 --installroot=${CONTAINER_PATH} \
 --releasever=8\
 clean all

buildah run -t ${CONTAINER_UUID} systemctl mask\
 console-getty.service\
 dev-hugepages.mount\
 dnf-makecache.timer\
 getty.target\
 kdump.service\
 sys-fs-fuse-connections.mount\
 systemd-homed.service\
 systemd-hostnamed.service\
 systemd-machine-id-commit.service\
 systemd-random-seed.service\
 systemd-remount-fs.service\
 systemd-resolved.service\
 systemd-udev-trigger.service\
 systemd-udevd.service\
 zfs.target\
 zfs-import.target\
 zfs-volumes.target

buildah run -t ${CONTAINER_UUID} systemctl enable\
 dbus-broker.service

clean_files

sed -i 's/driver = "overlay"/driver = "zfs"/' ${CONTAINER_PATH}/etc/containers/storage.conf
sed -i 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/' ${CONTAINER_PATH}/etc/pam.d/sshd

buildah config --volume /var/lib/containers ${CONTAINER_UUID}

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}

buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap:$(date +'%Y.%m.%d')-1
buildah rm -a
