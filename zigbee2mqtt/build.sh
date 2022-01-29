. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container base/nodejs16-devel:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(buildah run ${CONTAINER_UUID} mktemp -d)
if [ -f ./files/${ZIGBEE2MQTT_VERSION}.tar.gz ]; then
    tar xvf ./files/${ZIGBEE2MQTT_VERSION}.tar.gz -C ${CONTAINER_PATH}${TMP_DIR}
else
    pushd ${CONTAINER_PATH}${TMP_DIR}
        curl -L https://github.com/Koenkk/zigbee2mqtt/archive/refs/tags/${ZIGBEE2MQTT_VERSION}.tar.gz|tar xvz
    popd
fi

buildah run -t --workingdir=${TMP_DIR} ${CONTAINER_UUID} npm ci

CONTAINER_UUID=$(create_container base/nodejs16:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

mv -v ${TMP_DIR}/zigbee2mqtt-${ZIGBEE2MQTT_VERSION} ${CONTAINER_PATH}/usr/local/lib/zigbee2mqtt
rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 zigbee2mqtt.service

buildah config --volume /var/lib/zigbee2mqtt ${CONTAINER_UUID}
buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}

commit_container zigbee2mqtt:latest
