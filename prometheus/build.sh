#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz|tar xzv
popd
mv -v ${TMP_DIR}/prometheus-${PROMETHEUS_VERSION}.linux-amd64/{prometheus,promtool} ${CONTAINER_PATH}/usr/local/bin/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{prometheus,promtool}
mkdir -vp ${CONTAINER_PATH}/usr/share/prometheus
mv -v ${TMP_DIR}/prometheus-${PROMETHEUS_VERSION}.linux-amd64/{consoles,console_libraries,prometheus.yml} ${CONTAINER_PATH}/usr/share/prometheus/
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 prometheus.service

buildah config --volume /etc/prometheus ${CONTAINER_UUID}
buildah config --volume /var/lib/prometheus ${CONTAINER_UUID}

container_commit prometheus ${IMAGE_TAG}
