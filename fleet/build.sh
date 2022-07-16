#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

VERSION=$(jq -r .[0].version ./files/versions.json)
TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
        curl -L $(jq -r .[0].remote_url ./files/versions.json | sed "s;VERSION;${VERSION};g") | tar xzv
        curl -L $(jq -r .[1].remote_url ./files/versions.json | sed "s;VERSION;${VERSION};g") | tar xzv
    else
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L $(jq -r .[0].local_url ./files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};") | tar xzv
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L $(jq -r .[1].local_url ./files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};") | tar xzv
    fi
popd
mv -v ${TMP_DIR}/fleet_v${FLEET_VERSION}_linux/fleet ${CONTAINER_PATH}/usr/local/bin/fleet
mv -v ${TMP_DIR}/fleetctl_v${FLEET_VERSION}_linux/fleetctl ${CONTAINER_PATH}/usr/local/bin/fleetctl
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{fleet,fleetctl}
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 fleet.service

buildah config --volume /etc/fleet ${CONTAINER_UUID}
buildah config --volume /var/log/fleet ${CONTAINER_UUID}

container_commit fleet ${IMAGE_TAG}
