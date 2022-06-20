. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
if [ -f "./files/boundary_${BOUNDARY_VERSION}_linux_amd64.zip" ]; then
    unzip boundary_${BOUNDARY_VERSION}_linux_amd64.zip
else
    curl -L -O https://releases.hashicorp.com/boundary/${BOUNDARY_VERSION}/boundary_${BOUNDARY_VERSION}_linux_amd64.zip
    unzip boundary_${BOUNDARY_VERSION}_linux_amd64.zip
fi
popd
mv -v ${TMP_DIR}/boundary ${CONTAINER_PATH}/usr/local/bin/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/boundary
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 boundary.service

buildah config --volume /etc/boundary.d ${CONTAINER_UUID}
buildah config --volume /var/lib/boundary ${CONTAINER_UUID}

commit_container boundary:latest
