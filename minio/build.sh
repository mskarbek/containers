. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/systemd:$(date +'%Y.%m.%d')-1
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

curl -L -o ${CONTAINER_PATH}/usr/local/bin/minio https://dl.min.io/server/minio/release/linux-amd64/minio
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/*

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 minio.service

buildah config --volume /var/lib/minio ${CONTAINER_UUID}

buildah commit ${CONTAINER_UUID} ${REGISTRY}/minio:$(date +'%Y.%m.%d')-1
buildah rm -a
