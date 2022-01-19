. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container openjdk8-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "curl"
dnf_clean_cache
dnf_clean

TMP_DIR=$(mktemp -d)
if [ -f "./files/nexus-${NEXUS_VERSION}-unix.tar.gz" ]; then
    tar xvf ./files/nexus-${NEXUS_VERSION}-unix.tar.gz -C ${TMP_DIR}
else
    pushd ${TMP_DIR}
        curl -L https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz|tar xzv
    popd
fi
mkdir ${CONTAINER_PATH}/usr/lib/sonatype
pushd ${CONTAINER_PATH}/usr/lib/sonatype
    mv -v ${TMP_DIR}/nexus-${NEXUS_VERSION} ./
    mv -v ${TMP_DIR}/sonatype-work ./
    ln -s ./nexus-${NEXUS_VERSION} nexus
popd
rm -rf ${TMP_DIR}

rsync_rootfs

sed -i 's/=\.\.\/sonatype-work/=\/var\/lib\/sonatype-work/' ${CONTAINER_PATH}/usr/lib/sonatype/nexus/bin/nexus.vmoptions
if [ -f ./files/keystore.p12 ] && [ -f ./files/keystore.pass ]; then
    cp -v ./files/keystore.p12 ${CONTAINER_PATH}/usr/lib/sonatype/sonatype-work/nexus3/keystores/keystore.p12
    echo "-Djavax.net.ssl.keyStore=/var/lib/sonatype-work/nexus3/keystores/keystore.p12" >> ${CONTAINER_PATH}/usr/lib/sonatype/nexus/bin/nexus.vmoptions
    echo "-Djavax.net.ssl.keyStorePassword=$(cat ./files/keystore.pass)" >> ${CONTAINER_PATH}/usr/lib/sonatype/nexus/bin/nexus.vmoptions
fi

buildah run -t ${CONTAINER_UUID} systemctl enable\
 nexus.service\
 nexus-password.service

buildah config --volume /var/lib/sonatype-work ${CONTAINER_UUID}

commit_container nexus:latest
