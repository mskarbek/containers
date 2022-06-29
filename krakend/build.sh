#!/usr/bin/env bash
set -e

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/krakend.repo ${CONTAINER_PATH}/etc/yum.repos.d/krakend.repo
fi
cp -v ./files/RPM-GPG-KEY-krakend ${CONTAINER_PATH}/etc/pki/rpm-gpg/RPM-GPG-KEY-krakend
rpm --import --root=${CONTAINER_PATH} ./files/RPM-GPG-KEY-krakend
dnf_install "krakend"
dnf_cache_clean
dnf_clean

buildah run --network none ${CONTAINER_UUID} usermod -d /run/krakend krakend
buildah run --network none ${CONTAINER_UUID} systemctl enable\
 krakend.service
 
buildah config --volume /etc/krakend ${CONTAINER_UUID}

container_commit krakend ${IMAGE_TAG}
