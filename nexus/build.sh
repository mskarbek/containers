#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create openjdk8-jre ${1}

dnf_cache
dnf_install "curl"
dnf_cache_clean
dnf_clean

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz|tar xzv
popd
mkdir -vp ${CONTAINER_PATH}/usr/lib/sonatype
pushd ${CONTAINER_PATH}/usr/lib/sonatype
    mv -v ${TMP_DIR}/nexus-${NEXUS_VERSION} ./
    mv -v ${TMP_DIR}/sonatype-work ./
    ln -s ./nexus-${NEXUS_VERSION} nexus
popd
rm -vrf ${TMP_DIR}

rsync_rootfs

#TODO: keystore situation needs to be rethought
sed -i 's/=\.\.\/sonatype-work/=\/var\/lib\/sonatype-work/' ${CONTAINER_PATH}/usr/lib/sonatype/nexus/bin/nexus.vmoptions
if [ -f ./files/keystore.p12 ] && [ -f ./files/keystore.pass ]; then
    cp -v ./files/keystore.p12 ${CONTAINER_PATH}/usr/lib/sonatype/sonatype-work/nexus3/keystores/keystore.p12
    echo "-Djavax.net.ssl.keyStore=/var/lib/sonatype-work/nexus3/keystores/keystore.p12" >> ${CONTAINER_PATH}/usr/lib/sonatype/nexus/bin/nexus.vmoptions
    echo "-Djavax.net.ssl.keyStorePassword=$(cat ./files/keystore.pass)" >> ${CONTAINER_PATH}/usr/lib/sonatype/nexus/bin/nexus.vmoptions
fi

# Unfortunately, some mirrors use TLS certificates that, to be accepted, force LEGACY crypto policies
buildah run --network none ${CONTAINER_UUID} update-crypto-policies --set LEGACY
buildah run --network none ${CONTAINER_UUID} systemctl enable\
 nexus.service

buildah config --volume /var/lib/sonatype-work ${CONTAINER_UUID}

container_commit nexus ${IMAGE_TAG}
