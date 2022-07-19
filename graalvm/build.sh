#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create base ${1}

dnf_cache
dnf_install "curl bzip2-devel gcc gcc-c++ gcc-gfortran file fontconfig libcurl-devel make openssl-devel readline-devel tar which xz-devel zlib-devel findutils libstdc++ libstdc++-devel libstdc++-static zlib-static"
dnf_cache_clean
dnf_clean

buildah run --network none ${CONTAINER_UUID} fc-cache -f -v

VERSION=$(jq -r .[0].version ./files/versions.json)
PWD_DIR=$(pwd)
pushd ${CONTAINER_PATH}/usr/local/lib
    if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
        curl -L $(jq -r .[0].remote_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g") | tar xzv
    else
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L $(jq -r .[0].local_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};") | tar xzv
    fi
    ln -s ./graalvm-ce-java17-${VERSION} ./graalvm
popd
TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
        curl -L -O $(jq -r .[1].remote_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g")
    else
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -O $(jq -r .[1].local_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
    fi
popd
buildah run --network none --volume ${TMP_DIR}:/tmp/native-image:z ${CONTAINER_UUID} /usr/local/lib/graalvm/bin/gu install -L /tmp/native-image/$(jq -r .[1].file_name ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};")
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} alternatives --install /usr/bin/gu gu /usr/local/bin/gu-wrapper.sh 20000
for BIN in ${CONTAINER_PATH}/usr/local/lib/graalvm/bin/*; do
    BASE=$(basename ${BIN})
    if [ ! -e "${CONTAINER_PATH}/usr/bin/${BASE}" ]; then
        buildah run --network none ${CONTAINER_UUID} alternatives --install /usr/bin/${BASE} ${BASE} $(printf ${BIN} | sed "s;${CONTAINER_PATH};;") 20000
    fi
done

buildah config --env JAVA_HOME=/usr/local/lib/graalvm ${CONTAINER_UUID}
buildah config --env GRAALVM_HOME=/usr/local/lib/graalvm ${CONTAINER_UUID}

container_commit base/graalvm ${IMAGE_TAG}


container_create base/openjdk17-jdk ${1}

dnf_cache
dnf_install "curl bzip2-devel gcc gcc-c++ gcc-gfortran file fontconfig libcurl-devel make openssl-devel readline-devel tar which xz-devel zlib-devel findutils libstdc++ libstdc++-devel libstdc++-static zlib-static"
dnf_cache_clean
dnf_clean

buildah run --network none ${CONTAINER_UUID} fc-cache -f -v

VERSION=$(jq -r .[0].version ./files/versions.json)
PWD_DIR=$(pwd)
pushd ${CONTAINER_PATH}/usr/local/lib
    if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
        curl -L $(jq -r .[0].remote_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g") | tar xzv
    else
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L $(jq -r .[0].local_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};") | tar xzv
    fi
    ln -s ./graalvm-ce-java17-${VERSION} ./graalvm
popd
TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
        curl -L -O $(jq -r .[1].remote_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g")
    else
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -O $(jq -r .[1].local_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
    fi
popd
buildah run --network none --volume ${TMP_DIR}:/tmp/native-image:z ${CONTAINER_UUID} /usr/local/lib/graalvm/bin/gu install -L /tmp/native-image/$(jq -r .[1].file_name ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};")
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} alternatives --install /usr/bin/gu gu /usr/local/bin/gu-wrapper.sh 20000
for BIN in ${CONTAINER_PATH}/usr/local/lib/graalvm/bin/*; do
    BASE=$(basename ${BIN})
    if [ ! -e "${CONTAINER_PATH}/usr/bin/${BASE}" ]; then
        buildah run --network none ${CONTAINER_UUID} alternatives --install /usr/bin/${BASE} ${BASE} $(printf ${BIN} | sed "s;${CONTAINER_PATH};;") 20000
    fi
done

buildah config --env JAVA_HOME=/usr/local/lib/graalvm ${CONTAINER_UUID}
buildah config --env GRAALVM_HOME=/usr/local/lib/graalvm ${CONTAINER_UUID}

container_commit base/openjdk17-graalvm ${IMAGE_TAG}
