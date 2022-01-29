. ../meta/common.sh
. ./files/VERSIONS

BUILD_UUID=$(create_container base/nodejs16-devel:latest)
BUILD_PATH=$(buildah mount ${BUILD_UUID})

TMP_DIR=$(buildah run ${BUILD_UUID} mktemp -d)
if [ -f ./files/${ZIGBEE2MQTT_VERSION}.tar.gz ]; then
    tar xvf ./files/${ZIGBEE2MQTT_VERSION}.tar.gz -C ${BUILD_PATH}${TMP_DIR}
else
    pushd ${BUILD_PATH}${TMP_DIR}
        curl -L https://github.com/Koenkk/zigbee2mqtt/archive/refs/tags/${ZIGBEE2MQTT_VERSION}.tar.gz|tar xvz
    popd
fi

buildah run -t --workingdir=${TMP_DIR}/zigbee2mqtt-${ZIGBEE2MQTT_VERSION} ${BUILD_UUID} npm ci

CONTAINER_UUID=$(create_container base/nodejs16:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

mv -v ${BUILD_PATH}${TMP_DIR}/zigbee2mqtt-${ZIGBEE2MQTT_VERSION} ${CONTAINER_PATH}/usr/local/lib/zigbee2mqtt
rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 zigbee2mqtt.service

buildah config --volume /var/lib/zigbee2mqtt ${CONTAINER_UUID}
buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}

commit_container zigbee2mqtt:latest
