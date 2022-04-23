. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
if [ -f "./files/vault_${VAULT_VERSION}_linux_amd64.zip" ]; then
    unzip vault_${VAULT_VERSION}_linux_amd64.zip
else
    curl -L -O https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
    unzip vault_${VAULT_VERSION}_linux_amd64.zip
fi
popd
mv -v ${TMP_DIR}/vault ${CONTAINER_PATH}/usr/local/bin/vault
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/vault
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 vault.service

buildah config --volume /etc/vault.d ${CONTAINER_UUID}
buildah config --volume /var/lib/vault ${CONTAINER_UUID}

commit_container vault:latest
