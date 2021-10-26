. ../meta/functions.sh

CONTAINER_UUID=$(create_container openjdk11-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

MC_VERSION="5.0"

TMP_DIR=$(mktemp -d)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    tar xvf files/hazelcast-management-center-${MC_VERSION}.tar.gz -C ${TMP_DIR}
else
    pushd ${TMP_DIR}
        curl -L https://download.hazelcast.com/management-center/hazelcast-management-center-${MC_VERSION}.tar.gz|tar xzv
    popd
fi
mkdir ${CONTAINER_PATH}/usr/lib/hazelcast
pushd ${CONTAINER_PATH}/usr/lib/hazelcast
    mv -v ${TMP_DIR}/hazelcast-management-center-${MC_VERSION} ./
    ln -s hazelcast-management-center-${MC_VERSION} management-center
    ln -s hazelcast-management-center-${MC_VERSION}.jar management-center/hazelcast-management-center.jar
popd
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 hazelcast-mc.service

commit_container hazelcast-mc5:latest
