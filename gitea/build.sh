REGISTRY='10.88.0.1:8082'

CONTAINER_ID=$(buildah from ${REGISTRY}/openssh:latest)
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
 install git-core git-lfs
dnf -y\
 --installroot=${CONTAINER_PATH}\
 --releasever=8.4\
 clean all

buildah run -t ${CONTAINER_ID} systemctl unmask\
 systemd-logind.service

rm -rvf\
 ${CONTAINER_PATH}/var/cache/*\
 ${CONTAINER_PATH}/var/log/dnf*\
 ${CONTAINER_PATH}/var/log/yum*\
 ${CONTAINER_PATH}/var/log/hawkey*\
 ${CONTAINER_PATH}/var/log/rhsm\
 ${CONTAINER_PATH}/etc/yum.repos.d/host.repo

curl -L -o ${CONTAINER_PATH}/usr/local/bin/gitea https://dl.gitea.io/gitea/1.14.3/gitea-1.14.3-linux-amd64

chown -v root:root ${CONTAINER_PATH}/usr/local/bin/*
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/*

mkdir ${CONTAINER_PATH}{/etc,/var/lib}/gitea

rsync -hrvP --ignore-existing rootfs/ ${CONTAINER_PATH}/

buildah run -t ${CONTAINER_ID} systemctl enable gitea.service

buildah commit ${CONTAINER_ID} ${REGISTRY}/gitea:latest
buildah rm -a
