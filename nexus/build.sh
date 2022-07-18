#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create openjdk8-jre ${1}

dnf_cache
dnf_install "curl"
dnf_cache_clean
dnf_clean

NEXUS_VERSION=$(jq -r .[0].version ./files/versions.json)
NEXUS_REPOSITORY_DART_VERSION=$(jq -r .[1].version ./files/versions.json)
PWD_DIR=$(pwd)
TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
        curl -L $(jq -r .[0].remote_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${NEXUS_VERSION};g") | tar xzv
        curl -L -O $(jq -r .[1].remote_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${NEXUS_REPOSITORY_DART_VERSION};g")
    else
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L $(jq -r .[0].local_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${NEXUS_VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};") | tar xzv
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -O $(jq -r .[1].local_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${NEXUS_REPOSITORY_DART_VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
    fi
popd
mkdir -vp ${CONTAINER_PATH}/usr/lib/sonatype
pushd ${CONTAINER_PATH}/usr/lib/sonatype
    mv -v ${TMP_DIR}/nexus-${NEXUS_VERSION} ./
    mv -v ${TMP_DIR}/sonatype-work ./
    mv -v ${TMP_DIR}/nexus-repository-dart-${NEXUS_REPOSITORY_DART_VERSION}-bundle.kar ./nexus-${NEXUS_VERSION}/deploy/nexus-repository-dart-${NEXUS_REPOSITORY_DART_VERSION}-bundle.kar
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
