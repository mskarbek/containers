#!/usr/bin/env bash
set -eu

source ../meta/common.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} scratch
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_install "--disablerepo=* --enablerepo=fedora --enablerepo=updates glibc-minimal-langpack coreutils-single"
cp -v /etc/yum.repos.d/{fedora-{modular,updates-modular,updates}.repo,fedora.repo} ${CONTAINER_PATH}/etc/yum.repos.d/
dnf_install "ca-certificates"
dnf_clean

if [ -f ./files/*.pem ]; then
    cp -v ./files/*.pem ${CONTAINER_PATH}/etc/pki/ca-trust/source/anchors/
    buildah run --network none ${CONTAINER_UUID} update-ca-trust
fi

rsync_rootfs "--links"

buildah config --env='container=oci' ${CONTAINER_UUID}
buildah config --cmd='[ "/usr/bin/bash", "-l" ]' ${CONTAINER_UUID}

container_commit micro ${IMAGE_TAG}
