#!/usr/bin/env bash
. ./files/ENV

umask 0022

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
KERNEL_VERSION="4.18.0-348.el8"

TMP_DIR=$(mktemp -d)
mkdir -vp ${TMP_DIR}/{zfs,images}
mkdir -vp ./files/zfs

cat << EOF > ${TMP_DIR}/zfs/zfs-kmod.spec
Name:           zfs-kmod
Version:        ${ZFS_VERSION}
Release:        1.fake%{?dist}

Summary:        Kernel module(s)
Group:          System Environment/Kernel
License:        CDDL
URL:            https://github.com/openzfs/zfs

Requires:       zfs = %{version}
Conflicts:      zfs-dkms
Obsoletes:      kmod-spl
Obsoletes:      spl-kmod

%description
This package fakes ZFS kernel modules package as installation dependency for ZFS userland tools.

%prep

%install

%files

%changelog
* Mon Jul 12 2021 Marcin Skarbek <rpm@skarbek.name> ${ZFS_VERSION}-1.fake
- Initial package
EOF

cat << EOF > ${TMP_DIR}/hyperscale.repo
[hyperscale-main]
name=CentOS Stream 8 - Hyperscale Main
baseurl=file:///root/containers/base/files/hyperscale-main/
enabled=1
gpgcheck=0

[hyperscale-facebook]
name=CentOS Stream 8 - Hyperscale Facebook
baseurl=file:///root/containers/base/files/hyperscale-facebook/
enabled=1
gpgcheck=0
EOF

cp ./files/zfs-${ZFS_VERSION}.tar.gz ${TMP_DIR}/zfs/

VOL1_UUID=$(cat /proc/sys/kernel/random/uuid)
#VOL2_UUID=$(cat /proc/sys/kernel/random/uuid)

zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/${VOL1_UUID}
#zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/${VOL2_UUID}

podman volume create --opt type=zfs --opt device=${ZFS_POOL}/datafs/var/lib/volumes/storage/${VOL1_UUID} ${VOL1_UUID}
#podman volume create --opt type=zfs --opt device=${ZFS_POOL}/datafs/var/lib/volumes/storage/${VOL2_UUID} ${VOL2_UUID}

skopeo copy dir://$(pwd)/files/ubi-init containers-storage:registry.access.redhat.com/ubi8/ubi-init:8.5
podman run -d --name=${CONTAINER_UUID}\
 -v ${VOL1_UUID}:/var/lib/containers:z\
 -v $(pwd)/..:/root/containers:z\
 -v ${TMP_DIR}:/root/tmp:z\
 --privileged registry.access.redhat.com/ubi8/ubi-init:8.5
# -v ${VOL2_UUID}:/var/lib/volumes:z\

if [[ -z ${OFFLINE_BOOTSTRAP} ]]; then
    podman exec ${CONTAINER_UUID} rm -vf /etc/rhsm-host /etc/pki/entitlement-host /etc/yum.repos.d/ubi.repo
    podman exec ${CONTAINER_UUID} subscription-manager register --auto-attach --release=8.5 --username=${RHEL_USER} --password=${RHEL_PASS}
else
    podman exec ${CONTAINER_UUID} rm -vf /etc/yum.repos.d/ubi.repo
fi
podman exec ${CONTAINER_UUID} dnf -y update
podman exec ${CONTAINER_UUID} dnf -y install\
 --enablerepo=codeready-builder-for-rhel-8-x86_64-rpms\
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
podman exec ${CONTAINER_UUID} useradd mock
podman exec ${CONTAINER_UUID} cp -v /root/tmp/zfs/zfs-${ZFS_VERSION}.tar.gz /home/mock/
podman exec ${CONTAINER_UUID} cp -v /root/tmp/zfs/zfs-kmod.spec /home/mock/
podman exec -u mock -w /home/mock ${CONTAINER_UUID} tar xvf zfs-${ZFS_VERSION}.tar.gz
podman exec -u mock -w /home/mock/zfs-${ZFS_VERSION} ${CONTAINER_UUID} ./configure --with-spec=redhat
podman exec -u mock -w /home/mock/zfs-${ZFS_VERSION} ${CONTAINER_UUID} make -j1 rpm-utils
podman exec -u mock -w /home/mock ${CONTAINER_UUID} rpmbuild -bb ./zfs-kmod.spec
podman exec -w /home/mock ${CONTAINER_UUID} dnf -y install\
 ./zfs-${ZFS_VERSION}/libnvpair3-${ZFS_VERSION}-1.el8.x86_64.rpm\
 ./zfs-${ZFS_VERSION}/libuutil3-${ZFS_VERSION}-1.el8.x86_64.rpm\
 ./zfs-${ZFS_VERSION}/libzfs5-${ZFS_VERSION}-1.el8.x86_64.rpm\
 ./zfs-${ZFS_VERSION}/libzpool5-${ZFS_VERSION}-1.el8.x86_64.rpm\
 ./zfs-${ZFS_VERSION}/zfs-${ZFS_VERSION}-1.el8.x86_64.rpm\
 ./rpmbuild/RPMS/x86_64/zfs-kmod-${ZFS_VERSION}-1.fake.el8.x86_64.rpm
podman exec -w /home/mock ${CONTAINER_UUID} bash -exc "mv -v ./zfs-${ZFS_VERSION}/*.rpm /root/tmp/zfs/"
podman exec -w /home/mock ${CONTAINER_UUID} bash -exc "mv -v ./rpmbuild/RPMS/x86_64/*.rpm /root/tmp/zfs/"
podman exec ${CONTAINER_UUID} cp -v /root/tmp/hyperscale.repo /etc/yum.repos.d/
podman exec ${CONTAINER_UUID} dnf -y install\
 --exclude=container-selinux\
 buildah\
 java-1.8.0-openjdk-headless\
 skopeo\
 rsync
podman exec ${CONTAINER_UUID} sed -i 's/driver = "overlay"/driver = "zfs"/' /etc/containers/storage.conf
podman exec -w /root/containers/nexus/files ${CONTAINER_UUID} bash -ex ../../meta/gen_keystore.sh
for IMGAGE in {micro,base,systemd,minio,nginx,step-ca,openjdk8-jre,nexus};
do
    podman exec -e IMAGE_BOOTSTRAP=1 -w /root/containers/${IMGAGE} ${CONTAINER_UUID} bash -ex build.sh
    podman exec ${CONTAINER_UUID} mkdir -vp /root/tmp/images/${IMGAGE}
    podman exec ${CONTAINER_UUID} skopeo copy --format=oci containers-storage:${REGISTRY}/bootstrap/${IMGAGE}:latest dir:///root/tmp/images/${IMGAGE}
done

for IMGAGE in {micro,base,systemd,minio,nginx,step-ca,openjdk8-jre,nexus};
do
    skopeo copy --format=oci dir://${TMP_DIR}/images/${IMGAGE} containers-storage:${REGISTRY}/bootstrap/${IMGAGE}:latest
done

#podman rm -f ${CONTAINER_UUID}
#podman volume rm ${VOL1_UUID}
#zfs destroy -R ${ZFS_POOL}/datafs/var/lib/volumes/${VOL1_UUID}
mv -v ${TMP_DIR}/zfs/*.rpm ./files/zfs/
#rm -rf ${TMP_DIR}
