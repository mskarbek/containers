. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/bootstrap/systemd:$(date +'%Y.%m.%d')-1
else
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/systemd:$(date +'%Y.%m.%d')-1
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

FAKE_SERVICE_VERSION=0.22.7

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cp -v files/fake-service ${CONTAINER_PATH}/usr/local/bin/fake-service
else
    TMP_DIR=$(mktemp -d)
    pushd ${TMP_DIR}
        curl -L -O https://github.com/nicholasjackson/fake-service/releases/download/v${FAKE_SERVICE_VERSION}/fake_service_linux_amd64.zip
        unzip ./fake_service_linux_amd64.zip
        mv -v ./fake-service ${CONTAINER_PATH}/usr/local/bin/fake-service
    popd
    rm -rfv ${TMP_DIR}
fi
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/minio

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 fake-service.service

buildah config --volume /var/lib/minio ${CONTAINER_UUID}

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/fake-service:$(date +'%Y.%m.%d')-1
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/fake-service:$(date +'%Y.%m.%d')-1
fi
buildah rm -a
