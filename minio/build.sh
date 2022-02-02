. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ -f ./files/minio ] && [ -f ./files/mcli ]; then
    cp -v ./files/{minio,mcli} ${CONTAINER_PATH}/usr/local/bin/
else
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/minio https://dl.min.io/server/minio/release/linux-amd64/archive/minio.${MINIO_VERSION}
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/mcli https://dl.min.io/client/mc/release/linux-amd64/archive/mc.${MCLI_VERSION}
fi
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{minio,mcli}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 minio.service

buildah config --volume /etc/minio ${CONTAINER_UUID}
buildah config --volume /var/lib/minio ${CONTAINER_UUID}

commit_container minio:latest
