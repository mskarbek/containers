. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container python39:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "libtiff libjpeg libzip freetype libwebp libxml2 libxslt libpq libffi openssl"
dnf_clean_cache
dnf_clean

TMP_DIR=${CONTAINER_PATH}/tmp
if [ -f "./files/matrix_synapse-${SYNAPSE_VERSION}-py3-none-any.whl" ]; then
    cp -v ./files/matrix_synapse-${SYNAPSE_VERSION}-py3-none-any.whl ${TMP_DIR}
else
    curl -L -o ${TMP_DIR}/matrix_synapse-${SYNAPSE_VERSION}-py3-none-any.whl https://github.com/matrix-org/synapse/releases/download/v${SYNAPSE_VERSION}/matrix_synapse-${SYNAPSE_VERSION}-py3-none-any.whl
fi
buildah run ${CONTAINER_UUID} pip3 install /tmp/matrix_synapse-${SYNAPSE_VERSION}-py3-none-any.whl
rm -rf ${TMP_DIR}/*

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 synapse.service

buildah config --volume /etc/synapse ${CONTAINER_UUID}
#buildah config --volume /var/lib/synapse ${CONTAINER_UUID}

commit_container synapse:latest
