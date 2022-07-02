#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create openjdk11-jre ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://download.hazelcast.com/management-center/hazelcast-management-center-${MC_VERSION}.tar.gz|tar xzv
popd
mkdir -vp ${CONTAINER_PATH}/usr/lib/hazelcast
pushd ${CONTAINER_PATH}/usr/lib/hazelcast
    mv -v ${TMP_DIR}/hazelcast-management-center-${MC_VERSION} ./
    ln -s hazelcast-management-center-${MC_VERSION} management-center
    ln -s hazelcast-management-center-${MC_VERSION}.jar management-center/hazelcast-management-center.jar
popd
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 hazelcast-mc.service

container_commit hazelcast4-mc ${IMAGE_TAG}
