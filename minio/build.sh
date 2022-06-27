. ../meta/common.sh
. ./files/VERSIONS

if [ -z ${1} ]; then
    CONTAINER_UUID=$(create_container systemd latest)
else
    CONTAINER_UUID=$(create_container systemd ${1})
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

curl -L -o ${CONTAINER_PATH}/usr/local/bin/minio https://dl.min.io/server/minio/release/linux-amd64/archive/minio.${MINIO_VERSION}
curl -L -o ${CONTAINER_PATH}/usr/local/bin/mcli https://dl.min.io/client/mc/release/linux-amd64/archive/mc.${MCLI_VERSION}
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{minio,mcli}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 minio.service

buildah config --volume /etc/minio ${CONTAINER_UUID}
buildah config --volume /var/lib/minio ${CONTAINER_UUID}

commit_container minio ${IMAGE_TAG}
