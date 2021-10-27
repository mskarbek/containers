. ../meta/functions.sh

CONTAINER_UUID=$(create_container openjdk11-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

HC_VERSION="4.2.2"

TMP_DIR=$(mktemp -d)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    tar xvf files/hazelcast-${HC_VERSION}.tar.gz -C ${TMP_DIR}
else
    pushd ${TMP_DIR}
        curl -L https://download.hazelcast.com/download.jsp?version=hazelcast-${HC_VERSION}&type=tar&p=|tar xzv
    popd
fi
pushd ${CONTAINER_PATH}/usr/lib/
    mv -v ${TMP_DIR}/hazelcast-${HC_VERSION} ./
    ln -s hazelcast-${HC_VERSION} hazelcast
    rm -rf hazelcast/management-center
popd
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 hazelcast.service

commit_container hazelcast4:latest
