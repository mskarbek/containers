#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L -O https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
    unzip consul_${CONSUL_VERSION}_linux_amd64.zip
popd
mv -v ${TMP_DIR}/consul ${CONTAINER_PATH}/usr/local/bin/consul
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/consul
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 consul.service

buildah config --volume /etc/consul.d ${CONTAINER_UUID}
buildah config --volume /var/lib/consul ${CONTAINER_UUID}

container_commit consul ${IMAGE_TAG}
