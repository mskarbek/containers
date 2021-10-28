. ../meta/functions.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [[ -z ${STEPCA_VERSION} || -z ${STEPCLI_VERSION} ]]; then
    STEPCA_VERSION="0.17.6"
    STEPCLI_VERSION="0.17.7"
fi

TMP_DIR=$(mktemp -d)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    tar xvf ./files/step_linux_${STEPCLI_VERSION}_amd64.tar.gz -C ${TMP_DIR}
    tar xvf ./files/step-ca_linux_${STEPCA_VERSION}_amd64.tar.gz -C ${TMP_DIR}
else
    pushd ${TMP_DIR}
        curl -L https://github.com/smallstep/cli/releases/download/v0.17.6/step_linux_${STEPCLI_VERSION}_amd64.tar.gz|tar xzv
        curl -L https://github.com/smallstep/certificates/releases/download/v0.17.4/step-ca_linux_${STEPCA_VERSION}_amd64.tar.gz|tar xzv
    popd
fi
mv -v ${TMP_DIR}/step_${STEPCLI_VERSION}/bin/step ${CONTAINER_PATH}/usr/local/bin/step
mv -v ${TMP_DIR}/step-ca_${STEPCA_VERSION}/bin/step-ca ${CONTAINER_PATH}/usr/local/bin/step-ca
rm -rf ${TMP_DIR}

chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/step*

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 step-ca.service

buildah config --volume /var/lib/step-ca ${CONTAINER_UUID}

commit_container step-ca:latest
