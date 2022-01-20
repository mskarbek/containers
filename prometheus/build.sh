. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
if [ -f "./files/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz" ]; then
    tar xvf ./files/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz -C ${TMP_DIR}
else
    pushd ${TMP_DIR}
        curl -L https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz|tar xzv
    popd
fi
mv -v ${TMP_DIR}/prometheus-${PROMETHEUS_VERSION}.linux-amd64/{prometheus,promtool} ${CONTAINER_PATH}/usr/local/bin/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/*
mkdir -vp /usr/share/prometheus
mv -v ${TMP_DIR}/prometheus-${PROMETHEUS_VERSION}.linux-amd64/{consoles,console_libraries,prometheus.yml} /usr/share/prometheus/
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 prometheus.service

buildah config --volume /etc/prometheus ${CONTAINER_UUID}
buildah config --volume /var/lib/prometheus ${CONTAINER_UUID}

commit_container prometheus:latest
