. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} registry.access.redhat.com/ubi8/ubi:8.4
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

ZFS_VERSION="2.1.0"
KERNEL_VERSION="4.18.0-305.el8"

TMPDIR=$(mktemp -d)

buildah run -t ${CONTAINER_UUID} dnf -y\
 --disablerepo=ubi*\
 --releasever=8\
 --setopt=module_platform_id=platform:el8\
 --setopt=install_weak_deps=false\
 --nodocs\
 update

buildah run -t ${CONTAINER_UUID} dnf -y\
 --disablerepo=ubi*\
 --enablerepo=codeready-builder-for-rhel-8-x86_64-rpms\
 --releasever=8\
 --setopt=module_platform_id=platform:el8\
 --setopt=install_weak_deps=false\
 --nodocs\
 install\
 autoconf\
 automake\
 elfutils-libelf-devel\
 gcc\
 kernel-abi-stablelists-${KERNEL_VERSION}\
 kernel-devel-${KERNEL_VERSION}\
 kernel-headers-${KERNEL_VERSION}\
 kernel-rpm-macros\
 kmod\
 libaio-devel\
 libattr-devel\
 libblkid-devel\
 libffi-devel\
 libtirpc-devel\
 libtool\
 libudev-devel\
 libuuid-devel\
 make\
 ncompress\
 openssl-devel\
 python3\
 python3-cffi\
 python3-devel\
 python3-packaging\
 python3-setuptools\
 rpm-build\
 zlib-devel

buildah run -t ${CONTAINER_UUID} useradd mock

pushd ${TMPDIR}
curl -L https://github.com/openzfs/zfs/releases/download/zfs-${ZFS_VERSION}/zfs-${ZFS_VERSION}.tar.gz|tar xzv
popd

pushd ${CONTAINER_PATH}/home/mock
mv -v ${TMPDIR}/zfs-${ZFS_VERSION} ./
popd

buildah run -t ${CONTAINER_UUID} chown -Rv mock:mock /home/mock/zfs-${ZFS_VERSION}
buildah run --user mock -t ${CONTAINER_UUID} bash -c "cd /home/mock/zfs-${ZFS_VERSION}; ./configure --with-spec=redhat; make -j1 rpm-utils"

cat << EOF > ${CONTAINER_PATH}/home/mock/zfs-kmod.spec
Name:           zfs-kmod
Version:        ${ZFS_VERSION}
Release:        1.dummy%{?dist}

Summary:        Kernel module(s)
Group:          System Environment/Kernel
License:        CDDL
URL:            https://github.com/openzfs/zfs

Requires:       zfs = %{version}
Conflicts:      zfs-dkms
Obsoletes:      kmod-spl
Obsoletes:      spl-kmod

%description
This package contains the dummy ZFS kernel modules.

%prep

%install

%files

%changelog
* Mon Jul 12 2021 Marcin Skarbek <rpm@skarbek.name> ${ZFS_VERSION}-1.dummy
- Initial package
EOF

buildah run --user mock -t ${CONTAINER_UUID} bash -c "cd /home/mock; rpmbuild -bb ./zfs-kmod.spec"

pushd ${TMPDIR}
mv -v ${CONTAINER_PATH}/home/mock/zfs-${ZFS_VERSION}/*.rpm ./
mv -v ${CONTAINER_PATH}/home/mock/rpmbuild/RPMS/x86_64/*.rpm ./
popd

buildah rm -a

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} registry.access.redhat.com/ubi8/ubi:8.4
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

mkdir -pv ${CONTAINER_PATH}/var/cache/zfs
mv ${TMPDIR}/*.rpm ${CONTAINER_PATH}/var/cache/zfs/
rm -rf ${TMPDIR}

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

buildah run -t ${CONTAINER_UUID} dnf -y\
 --disablerepo=ubi*\
 --releasever=8\
 --setopt=module_platform_id=platform:el8\
 --setopt=install_weak_deps=false\
 --nodocs\
 update

buildah run -t ${CONTAINER_UUID} dnf -y\
 --disablerepo=ubi*\
 --releasever=8\
 --setopt=module_platform_id=platform:el8\
 --setopt=install_weak_deps=false\
 --nodocs\
 install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

buildah run -t ${CONTAINER_UUID} dnf -y\
 --disablerepo=ubi*\
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
 /var/cache/zfs/libnvpair3-${ZFS_VERSION}-1.el8.x86_64.rpm\
 /var/cache/zfs/libuutil3-${ZFS_VERSION}-1.el8.x86_64.rpm\
 /var/cache/zfs/libzfs5-${ZFS_VERSION}-1.el8.x86_64.rpm\
 /var/cache/zfs/libzpool5-${ZFS_VERSION}-1.el8.x86_64.rpm\
 /var/cache/zfs/zfs-${ZFS_VERSION}-1.el8.x86_64.rpm\
 /var/cache/zfs/zfs-kmod-${ZFS_VERSION}-1.dummy.el8.x86_64.rpm

buildah run -t ${CONTAINER_UUID} dnf -y\
 --disablerepo=ubi*\
 --releasever=8\
 --setopt=module_platform_id=platform:el8\
 --setopt=install_weak_deps=false\
 --nodocs\
 remove\
 dnf-plugin-subscription-manager\
 python3-subscription-manager-rhsm\
 subscription-manager\
 subscription-manager-rhsm-certificates

buildah run -t ${CONTAINER_UUID} dnf -y\
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

buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap-buildah:$(date +'%Y.%m.%d')-1
buildah rm -a
