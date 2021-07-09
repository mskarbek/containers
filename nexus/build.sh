. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/openjdk8-jre:$(date +'%Y.%m.%d')-1
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

NEXUS_VERSION="3.32.0-03"

TMPDIR=$(mktemp -d)

pushd ${TMPDIR}
curl -L https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz|tar xzv
popd

mkdir ${CONTAINER_PATH}/usr/lib/sonatype
pushd ${CONTAINER_PATH}/usr/lib/sonatype
mv -v ${TMPDIR}/nexus-${NEXUS_VERSION} ./
mv -v ${TMPDIR}/sonatype-work ./
ln -s nexus-${NEXUS_VERSION} nexus
popd

rm -rf ${TMPDIR}

rsync_rootfs

cp -v files/nexus.vmoptions ${CONTAINER_PATH}/usr/lib/sonatype/nexus/bin/nexus.vmoptions
cp -v files/keystore.p12 ${CONTAINER_PATH}/usr/lib/sonatype/sonatype-work/nexus3/keystores/keystore.p12

buildah run -t ${CONTAINER_UUID} systemctl enable\
 nexus.service

buildah config --volume /var/lib/sonatype-work ${CONTAINER_UUID}

buildah commit ${CONTAINER_UUID} ${REGISTRY}/nexus:$(date +'%Y.%m.%d')-1
buildah rm -a
