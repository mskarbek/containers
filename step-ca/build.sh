. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
if [ -f "./files/step-ca_linux_${STEPCA_VERSION}_amd64.tar.gz" ] && [ -f "./files/step_linux_${STEPCLI_VERSION}_amd64.tar.gz" ]; then
    tar xvf ./files/step-ca_linux_${STEPCA_VERSION}_amd64.tar.gz -C ${TMP_DIR}
    tar xvf ./files/step_linux_${STEPCLI_VERSION}_amd64.tar.gz -C ${TMP_DIR}
else
    pushd ${TMP_DIR}
        curl -L https://github.com/smallstep/certificates/releases/download/v${STEPCA_VERSION}/step-ca_linux_${STEPCA_VERSION}_amd64.tar.gz|tar xzv
        curl -L https://github.com/smallstep/cli/releases/download/v${STEPCLI_VERSION}/step_linux_${STEPCLI_VERSION}_amd64.tar.gz|tar xzv
    popd
fi
mv -v ${TMP_DIR}/step-ca_${STEPCA_VERSION}/bin/step-ca ${CONTAINER_PATH}/usr/local/bin/step-ca
mv -v ${TMP_DIR}/step_${STEPCLI_VERSION}/bin/step ${CONTAINER_PATH}/usr/local/bin/step
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/step*
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 step-ca.service

buildah config --volume /var/lib/step-ca ${CONTAINER_UUID}

commit_container step-ca:latest
