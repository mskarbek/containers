#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

VERSION=$(jq -r .[0].version ./files/versions.json)
TMP_DIR=$(mktemp -d)
PWD_DIR=$(pwd)
pushd ${TMP_DIR}
if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
    curl -L $(jq -r .[0].remote_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${STEPCA_VERSION};g") | tar xzv
else
    curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L $(jq -r .[0].local_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${STEPCA_VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};") | tar xzv
fi
popd
mv -v ${TMP_DIR}/template_${STEPCA_VERSION}/template ${CONTAINER_PATH}/usr/local/bin/template
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/template
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 template.service

buildah config --volume /var/lib/template ${CONTAINER_UUID}

container_commit template ${IMAGE_TAG}
