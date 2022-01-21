. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
if [ -f "./files/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz" ]; then
    tar xvf ./files/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz -C ${TMP_DIR}
else
    pushd ${TMP_DIR}
        curl -L https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz|tar xzv
    popd
fi
mv -v ${TMP_DIR}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/{alertmanager,amtool} ${CONTAINER_PATH}/usr/local/bin/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/*
mkdir -vp ${CONTAINER_PATH}/usr/share/alertmanager
mv -v ${TMP_DIR}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/alertmanager.yml ${CONTAINER_PATH}/usr/share/alertmanager/
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 alertmanager.service

buildah config --volume /etc/alertmanager ${CONTAINER_UUID}
buildah config --volume /var/lib/alertmanager ${CONTAINER_UUID}

commit_container alertmanager:latest
