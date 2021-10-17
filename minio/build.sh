. ../meta/functions.sh

CONTAINER_UUID=$(create_container systemd:latest)
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

commit_container minio:latest
