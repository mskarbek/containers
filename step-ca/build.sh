. ../meta/functions.sh

CONTAINER_ID=$(buildah from ${REGISTRY}/systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_ID})

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
curl -L https://github.com/smallstep/certificates/releases/download/v0.15.15/step-ca_linux_0.15.15_amd64.tar.gz|tar xzv
popd

mv -v ${TMP_DIR}/*/bin/step-ca ${CONTAINER_PATH}/usr/local/bin/

rm -rf ${TMP_DIR}

chown -v root:root ${CONTAINER_PATH}/usr/local/bin/*
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/*

rsync -hrvP --ignore-existing rootfs/ ${CONTAINER_PATH}/

buildah run -t ${CONTAINER_ID} systemctl enable\
 step-ca.service

buildah commit ${CONTAINER_ID} ${REGISTRY}/step-ca:latest
buildah rm -a
