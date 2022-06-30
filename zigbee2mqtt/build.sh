#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create base/nodejs16-devel ${1}

BUILD_UUID=${CONTAINER_UUID}
BUILD_PATH=${CONTAINER_PATH}

TMP_DIR=$(buildah run ${BUILD_UUID} mktemp -d)
pushd ${BUILD_PATH}${TMP_DIR}
    curl -L https://github.com/Koenkk/zigbee2mqtt/archive/refs/tags/${ZIGBEE2MQTT_VERSION}.tar.gz|tar xvz
popd

buildah run --workingdir=${TMP_DIR}/zigbee2mqtt-${ZIGBEE2MQTT_VERSION} ${BUILD_UUID} npm ci --no-audit --no-optional --no-update-notifier
buildah run --workingdir=${TMP_DIR}/zigbee2mqtt-${ZIGBEE2MQTT_VERSION} ${BUILD_UUID} npm run build
buildah run --workingdir=${TMP_DIR}/zigbee2mqtt-${ZIGBEE2MQTT_VERSION} ${BUILD_UUID} rm -rf ./node_modules
buildah run --workingdir=${TMP_DIR}/zigbee2mqtt-${ZIGBEE2MQTT_VERSION} ${BUILD_UUID} npm ci --production --no-audit --no-optional --no-update-notifier 


container_create nodejs16 ${1}

echo -e "${TXT_YELLOW}move: there is too much of a java script bullshit to print that in the log${TXT_CLEAR}"
mv ${BUILD_PATH}${TMP_DIR}/zigbee2mqtt-${ZIGBEE2MQTT_VERSION} ${CONTAINER_PATH}/usr/lib/zigbee2mqtt
rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 zigbee2mqtt.service

buildah config --volume /var/lib/zigbee2mqtt ${CONTAINER_UUID}

container_commit zigbee2mqtt ${IMAGE_TAG}
