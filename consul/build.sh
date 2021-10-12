
TMP_CONSUL=$(mktemp -d)
pushd ${TMP_CONSUL}
curl -L -O https://releases.hashicorp.com/consul/1.10.0/consul_1.10.0_linux_amd64.zip
unzip consul_1.10.0_linux_amd64.zip
popd

mv -v ${TMP_CONSUL}/consul ${CONTAINER_PATH}/usr/local/bin/

rm -rf ${TMP_CONSUL}

chown -v root:root ${CONTAINER_PATH}/usr/local/bin/*
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/*

mkdir ${CONTAINER_PATH}/{etc,var/lib}/consul

rsync -hrvP --ignore-existing rootfs/ ${CONTAINER_PATH}/

buildah run -t ${CONTAINER_ID} systemctl enable consul.service

buildah commit ${CONTAINER_ID} ${REGISTRY}/consul:latest
buildah rm -a




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
