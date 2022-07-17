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
mv -v ${TMP_DIR}/kuma-${VERSION}/bin/{kuma-cp,kumactl} ${CONTAINER_PATH}/usr/local/bin/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{kuma-cp,kumactl}
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 kuma-cp.service

buildah config --volume /etc/kuma ${CONTAINER_UUID}
buildah config --volume /var/log/kuma ${CONTAINER_UUID}

container_commit kuma-cp ${IMAGE_TAG}
