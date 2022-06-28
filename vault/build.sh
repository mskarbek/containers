#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L -O https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
    unzip vault_${VAULT_VERSION}_linux_amd64.zip
popd
mv -v ${TMP_DIR}/vault ${CONTAINER_PATH}/usr/local/bin/vault
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/vault
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 vault.service

buildah config --volume /etc/vault.d ${CONTAINER_UUID}
buildah config --volume /var/lib/vault ${CONTAINER_UUID}

container_commit vault ${IMAGE_TAG}
