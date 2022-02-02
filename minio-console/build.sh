. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ -f ./files/minio-console ]; then
    cp -v ./files/minio-console ${CONTAINER_PATH}/usr/local/bin/
else
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/minio-console https://github.com/minio/console/releases/download/v${MINIO_CONSOLE_VERSION}/console-linux-amd64
fi
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/minio-console

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 minio-console.service

buildah config --volume /etc/minio-console ${CONTAINER_UUID}

commit_container minio-console:latest
