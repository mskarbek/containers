#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create openjdk17-jre ${1}

VERSION=$(jq -r .[0].version ./files/versions.json)
PWD_DIR=$(pwd)
TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
        curl -L $(jq -r .[0].remote_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g") | tar xzv
    else
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L $(jq -r .[0].local_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};") | tar xzv
    fi
popd
pushd ${CONTAINER_PATH}/usr/lib
    mv -v ${TMP_DIR}/keycloak-${VERSION} ./
    ln -s ./keycloak-${VERSION} keycloak
    mv -v ${CONTAINER_PATH}/usr/lib/keycloak/conf ${CONTAINER_PATH}/usr/share/keycloak
popd
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 keycloak.service

buildah config --volume /usr/lib/keycloak/conf ${CONTAINER_UUID}
buildah config --volume /usr/lib/keycloak/data ${CONTAINER_UUID}

container_commit keycloak ${IMAGE_TAG}
