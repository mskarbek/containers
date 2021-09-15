. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/bootstrap/openjdk8-jre:$(date +'%Y.%m.%d')-1
else
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/openjdk8-jre:$(date +'%Y.%m.%d')-1
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

sed -i 's/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/0\.0\.0\.0:9092/' ${CONTAINER_PATH}/opt/kafka_2.13-2.8.0/config/server.properties

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 kafka.service\
 zookeeper.service

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/kafka:$(date +'%Y.%m.%d')-1
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/kafka:$(date +'%Y.%m.%d')-1
fi
buildah rm -a
