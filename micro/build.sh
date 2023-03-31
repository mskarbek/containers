#!/usr/bin/env bash
set -eu

source ../meta/common.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} scratch
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ${OS_TYPE} = "rhel" ]; then
    ENABLE_REPO="rhel-9-for-x86_64-baseos-rpms"
elif [ ${OS_TYPE} = "alma" ]; then
    ENABLE_REPO="baseos"
else
    printf "ERROR: Missing or incorrect OS_TYPE variable." >&2
    exit 1
fi

dnf_install "--disablerepo=* --enablerepo=${ENABLE_REPO} glibc-minimal-langpack coreutils-single"
if [ -f ./files/proxy.repo ] && [ ${IMAGE_BOOTSTRAP} != "true" ]; then
    cp -v ./files/proxy.repo ${CONTAINER_PATH}/etc/yum.repos.d/proxy.repo
fi
dnf_install "--disablerepo=* --enablerepo=${ENABLE_REPO} ca-certificates"
dnf_clean

if [ -f ./files/*.pem ]; then
    cp -v ./files/*.pem ${CONTAINER_PATH}/etc/pki/ca-trust/source/anchors/
    buildah run --network none ${CONTAINER_UUID} update-ca-trust
fi

rsync_rootfs "--links"

buildah config --env='container=oci' ${CONTAINER_UUID}
buildah config --env='SYSTEMD_LOG_TARGET=console' ${CONTAINER_UUID}
buildah config --cmd='[ "/usr/bin/bash", "-l" ]' ${CONTAINER_UUID}

container_commit micro ${IMAGE_TAG}
