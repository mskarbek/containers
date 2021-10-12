. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/bootstrap/systemd:latest
else
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/systemd:latest
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cp -v files/minio ${CONTAINER_PATH}/usr/local/bin/minio
else
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/minio https://dl.min.io/server/minio/release/linux-amd64/minio
fi
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/minio

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 minio.service

buildah config --volume /var/lib/minio ${CONTAINER_UUID}

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/minio:latest
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/minio:latest
fi
buildah rm -a
