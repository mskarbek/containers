CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} registry.access.redhat.com/ubi8/ubi:8.4
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

ZFS_VERSION="2.1.1"
KERNEL_VERSION="4.18.0-305.el8"

TMPDIR=$(mktemp -d)

ln -s /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo

dnf -y\
 --installroot=${CONTAINER_PATH}\
 --disablerepo=ubi*\
 --releasever=8\
 --setopt=module_platform_id=platform:el8\
 --setopt=install_weak_deps=false\
 --nodocs\
 update

dnf -y\
 --installroot=${CONTAINER_PATH} \
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
buildah run --user mock -t ${CONTAINER_UUID} bash -c "cd /home/mock/zfs-${ZFS_VERSION}; ./configure --with-spec=redhat; make -j1 rpm-utils rpm-kmod"

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

mkdir -v ./zfs

pushd ./zfs
mv -v ${CONTAINER_PATH}/home/mock/zfs-${ZFS_VERSION}/*.rpm ./
mv -v ${CONTAINER_PATH}/home/mock/rpmbuild/RPMS/x86_64/*.rpm ./
popd

buildah rm -a
