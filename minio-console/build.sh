. ../meta/common.sh
. ./files/VERSIONS

if [ -z ${1} ]; then
    CONTAINER_UUID=$(create_container systemd latest)
else
    CONTAINER_UUID=$(create_container systemd ${1})
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

curl -L -o ${CONTAINER_PATH}/usr/local/bin/minio-console https://github.com/minio/console/releases/download/v${MINIO_CONSOLE_VERSION}/console-linux-amd64
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/minio-console

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 minio-console.service

buildah config --volume /etc/minio-console ${CONTAINER_UUID}

commit_container minio-console ${IMAGE_TAG}
