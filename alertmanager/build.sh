#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

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
mv -v ${TMP_DIR}/alertmanager-${VERSION}.linux-amd64/{alertmanager,amtool} ${CONTAINER_PATH}/usr/local/bin/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{alertmanager,amtool}
mkdir -vp ${CONTAINER_PATH}/usr/share/alertmanager
mv -v ${TMP_DIR}/alertmanager-${VERSION}.linux-amd64/alertmanager.yml ${CONTAINER_PATH}/usr/share/alertmanager/alertmanager.yml
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 alertmanager.service

buildah config --volume /etc/alertmanager ${CONTAINER_UUID}
buildah config --volume /var/lib/alertmanager ${CONTAINER_UUID}

container_commit alertmanager ${IMAGE_TAG}
