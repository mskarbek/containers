#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create openssh ${1}

dnf_cache
dnf_install "hostname perl policycoreutils policycoreutils-python-utils checkpolicy git libxcrypt-compat tar"
VERSION=$(jq -r .[0].version ./files/versions.json)
TMP_DIR=$(mktemp -d)
if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
    curl -L -o ${TMP_DIR}/$(jq -r .[0].file_name ./files/versions.json | sed "s;VERSION;${VERSION};g") $(jq -r .[0].remote_url ./files/versions.json | sed "s;VERSION;${VERSION};g")
else
    curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -o ${TMP_DIR}/$(jq -r .[0].file_name ./files/versions.json | sed "s;VERSION;${VERSION};g") $(jq -r .[0].local_url ./files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
fi
rpm -ivh --noscripts --root=${CONTAINER_PATH} ${TMP_DIR}/$(jq -r .[0].file_name ./files/versions.json | sed "s;VERSION;${VERSION};g")
rm -vrf ${TMP_DIR}
dnf_cache_clean
dnf_clean

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 gitlab-config.service

buildah config --volume /etc/gitlab ${CONTAINER_UUID}
buildah config --volume /var/log/gitlab ${CONTAINER_UUID}
buildah config --volume /var/opt/gitlab ${CONTAINER_UUID}

container_commit gitlab-ce ${IMAGE_TAG}
