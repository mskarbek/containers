. ../meta/functions.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

STEPCA_VERSION="0.17.4"
STEPCLI_VERSION="0.17.6"

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cp -v files/step-ca ${CONTAINER_PATH}/usr/local/bin/step-ca
    cp -v files/step ${CONTAINER_PATH}/usr/local/bin/step
else
    TMP_DIR=$(mktemp -d)
    pushd ${TMP_DIR}
        curl -L https://github.com/smallstep/cli/releases/download/v0.17.6/step_linux_${STEPCLI_VERSION}_amd64.tar.gz|tar xzv
        curl -L https://github.com/smallstep/certificates/releases/download/v0.17.4/step-ca_linux_${STEPCA_VERSION}_amd64.tar.gz|tar xzv
    popd
    mv -v ${TMP_DIR}/step-ca_${STEPCA_VERSION}/bin/step-ca ${CONTAINER_PATH}/usr/local/bin/step-ca
    mv -v ${TMP_DIR}/step_${STEPCA_VERSION}/bin/step ${CONTAINER_PATH}/usr/local/bin/step
    rm -rf ${TMP_DIR}
fi

chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/step*

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 step-ca.service

buildah config --volume /var/lib/step-ca ${CONTAINER_UUID}

commit_container step-ca:latest
