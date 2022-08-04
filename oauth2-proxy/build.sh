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
mv -v ${TMP_DIR}/oauth2-proxy-v${VERSION}.linux-amd64/oauth2-proxy ${CONTAINER_PATH}/usr/local/bin/oauth2-proxy
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/oauth2-proxy
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 oauth2-proxy.service

buildah config --volume /etc/oauth2-proxy ${CONTAINER_UUID}

container_commit oauth2-proxy ${IMAGE_TAG}
