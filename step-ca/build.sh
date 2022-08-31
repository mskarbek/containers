#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

STEPCA_VERSION=$(jq -r .[0].version ./files/versions.json)
STEPCLI_VERSION=$(jq -r .[1].version ./files/versions.json)
TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
    curl -L $(jq -r .[0].remote_url ./files/versions.json | sed "s;VERSION;${STEPCA_VERSION};g") | tar xzv
    curl -L $(jq -r .[1].remote_url ./files/versions.json | sed "s;VERSION;${STEPCLI_VERSION};g") | tar xzv
else
    curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L $(jq -r .[0].local_url ./files/versions.json | sed "s;VERSION;${STEPCA_VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};") | tar xzv
    curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L $(jq -r .[1].local_url ./files/versions.json | sed "s;VERSION;${STEPCLI_VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};") | tar xzv
fi
popd
mv -v ${TMP_DIR}/step-ca_${STEPCA_VERSION}/bin/step-ca ${CONTAINER_PATH}/usr/local/bin/step-ca
mv -v ${TMP_DIR}/step_${STEPCLI_VERSION}/bin/step ${CONTAINER_PATH}/usr/local/bin/step
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{step-ca,step}
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 step-ca.service

buildah config --volume /var/lib/step-ca ${CONTAINER_UUID}

container_commit step-ca ${IMAGE_TAG}
