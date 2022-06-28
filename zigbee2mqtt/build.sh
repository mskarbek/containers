. ../meta/common.sh
. ./files/VERSIONS

BUILD_UUID=$(create_container base/nodejs16-devel ${IMAGE_TAG})
BUILD_PATH=$(buildah mount ${BUILD_UUID})
#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(buildah run ${BUILD_UUID} mktemp -d)
if [ -f ./files/${ZIGBEE2MQTT_VERSION}.tar.gz ]; then
    tar xvf ./files/${ZIGBEE2MQTT_VERSION}.tar.gz -C ${BUILD_PATH}${TMP_DIR}
else
    pushd ${BUILD_PATH}${TMP_DIR}
        curl -L https://github.com/Koenkk/zigbee2mqtt/archive/refs/tags/${ZIGBEE2MQTT_VERSION}.tar.gz|tar xvz
    popd
fi

buildah run --workingdir=${TMP_DIR}/zigbee2mqtt-${ZIGBEE2MQTT_VERSION} ${BUILD_UUID} npm ci --no-audit --no-optional --no-update-notifier
buildah run --workingdir=${TMP_DIR}/zigbee2mqtt-${ZIGBEE2MQTT_VERSION} ${BUILD_UUID} npm run build
buildah run --workingdir=${TMP_DIR}/zigbee2mqtt-${ZIGBEE2MQTT_VERSION} ${BUILD_UUID} rm -vrf ./node_modules
buildah run --workingdir=${TMP_DIR}/zigbee2mqtt-${ZIGBEE2MQTT_VERSION} ${BUILD_UUID} npm ci --production --no-audit --no-optional --no-update-notifier 


container_create base/nodejs16 ${1}

mv -v ${BUILD_PATH}${TMP_DIR}/zigbee2mqtt-${ZIGBEE2MQTT_VERSION} ${CONTAINER_PATH}/usr/lib/zigbee2mqtt
rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 zigbee2mqtt.service

buildah config --volume /var/lib/zigbee2mqtt ${CONTAINER_UUID}
buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

container_commit zigbee2mqtt ${IMAGE_TAG}
