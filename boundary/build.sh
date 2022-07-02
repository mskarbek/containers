#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L -O https://releases.hashicorp.com/boundary/${BOUNDARY_VERSION}/boundary_${BOUNDARY_VERSION}_linux_amd64.zip
    unzip boundary_${BOUNDARY_VERSION}_linux_amd64.zip
popd
mv -v ${TMP_DIR}/boundary ${CONTAINER_PATH}/usr/local/bin/boundary
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/boundary
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 boundary.service

buildah config --volume /etc/boundary.d ${CONTAINER_UUID}
buildah config --volume /var/lib/boundary ${CONTAINER_UUID}

container_commit boundary ${IMAGE_TAG}
