. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/bootstrap/openjdk8-jre:latest
else
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/openjdk8-jre:latest
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    tar -xvf ./files/kafka_2.13-2.8.0.tgz -C ${CONTAINER_PATH}/opt/
else
    TMP_DIR=$(mktemp -d)
    pushd ${TMP_DIR}
        curl -L -O https://dlcdn.apache.org/kafka/2.8.0/kafka_2.13-2.8.0.tgz
        tar -xvf ./kafka_2.13-2.8.0.tgz -C ${CONTAINER_PATH}/opt/
    popd
    rm -rfv ${TMP_DIR}
fi
ln -s /opt/kafka_2.13-2.8.0 ${CONTAINER_PATH}/opt/kafka

rsync_rootfs
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/*

buildah run -t ${CONTAINER_UUID} systemctl enable\
 kafka.service\
 zookeeper.service

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/kafka:latest
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/kafka:latest
fi
buildah rm -a
