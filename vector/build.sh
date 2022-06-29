#!/usr/bin/env bash
set -e

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/vector.repo ${CONTAINER_PATH}/etc/yum.repos.d/vector.repo
fi
cp -v ./files/RPM-GPG-KEY-vector ${CONTAINER_PATH}/etc/pki/rpm-gpg/RPM-GPG-KEY-vector
rpm --import --root=${CONTAINER_PATH} ./files/RPM-GPG-KEY-vector
dnf_install "vector"
dnf_cache_clean
dnf_clean

mkdir -vp ${CONTAINER_PATH}/usr/share/vector
mv -v ${CONTAINER_PATH}/etc/vector/* ${CONTAINER_PATH}/usr/share/vector/

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 vector.service
 
buildah config --volume /etc/vector ${CONTAINER_UUID}
buildah config --volume /var/lib/vector ${CONTAINER_UUID}

container_commit vector ${IMAGE_TAG}
