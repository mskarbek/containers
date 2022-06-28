#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create python3 ${1}

dnf_cache
dnf_install "libtiff libjpeg libzip freetype libwebp libxml2 libxslt libpq libffi openssl"
dnf_cache_clean
dnf_clean

TMP_DIR=${CONTAINER_PATH}/tmp
curl -L -o ${TMP_DIR}/matrix_synapse-${SYNAPSE_VERSION}-py3-none-any.whl https://github.com/matrix-org/synapse/releases/download/v${SYNAPSE_VERSION}/matrix_synapse-${SYNAPSE_VERSION}-py3-none-any.whl
buildah run ${CONTAINER_UUID} pip3 install /tmp/matrix_synapse-${SYNAPSE_VERSION}-py3-none-any.whl
rm -vrf ${TMP_DIR}/*

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 synapse.service

buildah config --volume /etc/synapse ${CONTAINER_UUID}
#buildah config --volume /var/lib/synapse ${CONTAINER_UUID}

container_commit synapse ${IMAGE_TAG}
