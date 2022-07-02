#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://github.com/smallstep/certificates/releases/download/v${STEPCA_VERSION}/step-ca_linux_${STEPCA_VERSION}_amd64.tar.gz|tar xzv
    curl -L https://github.com/smallstep/cli/releases/download/v${STEPCLI_VERSION}/step_linux_${STEPCLI_VERSION}_amd64.tar.gz|tar xzv
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
