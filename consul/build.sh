. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
if [ -f "./files/consul_${CONSUL_VERSION}_linux_amd64.zip" ]; then
    unzip consul_${CONSUL_VERSION}_linux_amd64.zip
else
    curl -L -O https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
    unzip consul_${CONSUL_VERSION}_linux_amd64.zip
fi
popd
mv -v ${TMP_DIR}/consul ${CONTAINER_PATH}/usr/local/bin/consul
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/consul
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 consul.service

buildah config --volume /etc/consul.d ${CONTAINER_UUID}
buildah config --volume /var/lib/consul ${CONTAINER_UUID}

commit_container consul:latest
