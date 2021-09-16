REGISTRY='10.88.0.1:8082'

CONTAINER_ID=$(buildah from ${REGISTRY}/systemd:$(date +'%Y.%m.%d')-1)
CONTAINER_PATH=$(buildah mount ${CONTAINER_ID})

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

buildah commit ${CONTAINER_ID} ${REGISTRY}/consul:$(date +'%Y.%m.%d')-1
buildah rm -a
