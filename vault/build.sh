#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

VERSION=$(jq -r .[0].version ./files/versions.json)
PWD_DIR=$(pwd)
TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
        curl -L -O $(jq -r .[0].remote_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g")
    else
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -O $(jq -r .[0].local_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
    fi
    unzip ./$(jq -r .[0].file_name ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};")
popd
mv -v ${TMP_DIR}/vault ${CONTAINER_PATH}/usr/local/bin/vault
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/vault
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 vault.service

buildah config --volume /etc/vault.d ${CONTAINER_UUID}
buildah config --volume /var/lib/vault ${CONTAINER_UUID}

container_commit vault ${IMAGE_TAG}
