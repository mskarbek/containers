. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/bootstrap/openjdk8-jre:$(date +'%Y.%m.%d')-1
else
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/openjdk8-jre:$(date +'%Y.%m.%d')-1
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

NEXUS_VERSION="3.34.0-01"

TMPDIR=$(mktemp -d)

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    tar xvf files/nexus-${NEXUS_VERSION}-unix.tar.gz -C ${TMPDIR}
else
    pushd ${TMPDIR}
    curl -L https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz|tar xzv
    #curl -L http://10.88.0.249:8081/repository/raw-hosted-stuff/nexus/${NEXUS_VERSION}/nexus-${NEXUS_VERSION}-unix.tar.gz|tar xzv
    popd
fi

mkdir ${CONTAINER_PATH}/usr/lib/sonatype
pushd ${CONTAINER_PATH}/usr/lib/sonatype
mv -v ${TMPDIR}/nexus-${NEXUS_VERSION} ./
mv -v ${TMPDIR}/sonatype-work ./
ln -s nexus-${NEXUS_VERSION} nexus
popd

rm -rf ${TMPDIR}

rsync_rootfs

if [[ -f files/keystore.p12 && -f files/nexus.vmoptions ]]; then
    cp -v files/nexus.vmoptions ${CONTAINER_PATH}/usr/lib/sonatype/nexus/bin/nexus.vmoptions
    cp -v files/keystore.p12 ${CONTAINER_PATH}/usr/lib/sonatype/sonatype-work/nexus3/keystores/keystore.p12
fi

buildah run -t ${CONTAINER_UUID} systemctl enable\
 nexus.service

buildah config --volume /var/lib/sonatype-work ${CONTAINER_UUID}

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/nexus:$(date +'%Y.%m.%d')-1
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/nexus:$(date +'%Y.%m.%d')-1
fi
buildah rm -a
