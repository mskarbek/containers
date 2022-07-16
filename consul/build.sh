#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

VERSION=$(jq -r .[0].version ./files/versions.json)
TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
        curl -L -O $(jq -r .[0].remote_url ./files/versions.json | sed "s;VERSION;${VERSION};g")
    else
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -O $(jq -r .[0].local_url ./files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
    fi
    unzip ./$(jq -r .[0].file_name ./files/versions.json | sed "s;VERSION;${VERSION};")
popd
mv -v ${TMP_DIR}/consul ${CONTAINER_PATH}/usr/local/bin/consul
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/consul
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 consul.service

buildah config --volume /etc/consul.d ${CONTAINER_UUID}
buildah config --volume /var/lib/consul ${CONTAINER_UUID}

container_commit consul ${IMAGE_TAG}
