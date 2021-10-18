. ../meta/functions.sh

CONTAINER_UUID=$(create_container openjdk8-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

NEXUS_VERSION="3.34.1-01"

TMP_DIR=$(mktemp -d)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    tar xvf files/nexus-${NEXUS_VERSION}-unix.tar.gz -C ${TMP_DIR}
else
    pushd ${TMP_DIR}
        curl -L https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz|tar xzv
    popd
fi
mkdir ${CONTAINER_PATH}/usr/lib/sonatype
pushd ${CONTAINER_PATH}/usr/lib/sonatype
    mv -v ${TMP_DIR}/nexus-${NEXUS_VERSION} ./
    mv -v ${TMP_DIR}/sonatype-work ./
    ln -s nexus-${NEXUS_VERSION} nexus
popd
rm -rf ${TMP_DIR}

rsync_rootfs

if [[ -f files/keystore.p12 && -f files/nexus.vmoptions ]]; then
    cp -v files/nexus.vmoptions ${CONTAINER_PATH}/usr/lib/sonatype/nexus/bin/nexus.vmoptions
    cp -v files/keystore.p12 ${CONTAINER_PATH}/usr/lib/sonatype/sonatype-work/nexus3/keystores/keystore.p12
fi

buildah run -t ${CONTAINER_UUID} systemctl enable\
 nexus.service

buildah config --volume /var/lib/sonatype-work ${CONTAINER_UUID}

commit_container nexus:latest
