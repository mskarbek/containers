#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
    cp -v ./files/krakend.repo ${CONTAINER_PATH}/etc/yum.repos.d/krakend.repo
fi
dnf_install "krakend"
dnf_cache_clean
dnf_clean

buildah run --network none ${CONTAINER_UUID} usermod -d /run/krakend krakend
buildah run --network none ${CONTAINER_UUID} systemctl enable\
 krakend.service
 
buildah config --volume /etc/krakend ${CONTAINER_UUID}

container_commit krakend ${IMAGE_TAG}
