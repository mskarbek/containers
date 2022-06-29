#!/usr/bin/env bash
set -e

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/couchdb.repo ${CONTAINER_PATH}/etc/yum.repos.d/couchdb.repo
fi
cp -v ./files/RPM-GPG-KEY-couchdb ${CONTAINER_PATH}/etc/pki/rpm-gpg/RPM-GPG-KEY-couchdb
rpm --import --root=${CONTAINER_PATH} ./files/RPM-GPG-KEY-couchdb
dnf_install "couchdb"
dnf_cache_clean
dnf_clean

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 couchdb.service

buildah config --volume /opt/couchdb/etc/local.d ${CONTAINER_UUID}
buildah config --volume /var/lib/couchdb ${CONTAINER_UUID}
buildah config --volume /var/log/couchdb ${CONTAINER_UUID}

container_commit couchdb ${IMAGE_TAG}
