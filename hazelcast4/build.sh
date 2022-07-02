#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create openjdk11-jre ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://download.hazelcast.com/download.jsp?version=hazelcast-${HC_VERSION}&type=tar&p=|tar xzv
popd
pushd ${CONTAINER_PATH}/usr/lib/
    mv -v ${TMP_DIR}/hazelcast-${HC_VERSION} ./
    ln -s hazelcast-${HC_VERSION} hazelcast
    rm -vrf hazelcast/management-center
popd
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 hazelcast.service

container_commit hazelcast4 ${IMAGE_TAG}
