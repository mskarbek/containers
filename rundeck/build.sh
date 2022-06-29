#!/usr/bin/env bash
set -e

source ../meta/common.sh

container_create openjdk11-jre ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/rundeck.repo ${CONTAINER_PATH}/etc/yum.repos.d/rundeck.repo
fi
dnf_install "rundeck git-core"
dnf_cache_clean
dnf_clean

ln -s $(ls -1 ${CONTAINER_PATH}/var/lib/rundeck/bootstrap) ${CONTAINER_PATH}/var/lib/rundeck/bootstrap/rundeck.war

#mkdir -vp ${CONTAINER_PATH}/usr/share/rundeck
#mv -v ${CONTAINER_PATH}/etc/rundeck/* ${CONTAINER_PATH}/usr/share/rundeck/
rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 rundeckd.service

#buildah config --volume /etc/rundeck ${CONTAINER_UUID}
buildah config --volume /var/log/rundeck ${CONTAINER_UUID}

container_commit rundeck ${IMAGE_TAG}
