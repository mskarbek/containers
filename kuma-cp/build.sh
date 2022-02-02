. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
if [ -f "./files/kuma-${KUMA_VERSION}-rhel-amd64.tar.gz" ]; then
    tar xvf ./files/kuma-${KUMA_VERSION}-rhel-amd64.tar.gz -C ${TMP_DIR}
else
    pushd ${TMP_DIR}
        curl -L https://download.konghq.com/mesh-alpine/kuma-${KUMA_VERSION}-rhel-amd64.tar.gz|tar xzv
    popd
fi
mv -v ${TMP_DIR}/kuma-${KUMA_VERSION}/bin/{kuma-cp,kumactl} ${CONTAINER_PATH}/usr/local/bin/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{kuma-cp,kumactl}
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 kuma-cp.service

buildah config --volume /etc/kuma ${CONTAINER_UUID}
buildah config --volume /var/log/kuma ${CONTAINER_UUID}

commit_container kuma-cp:latest
