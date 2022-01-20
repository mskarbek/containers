. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
if [ -f "./files/consul_${CONSUL_VERSION}_linux_amd64.zip" ]; then
    pushd ${TMP_DIR}
        unzip consul_${CONSUL_VERSION}_linux_amd64.zip
    popd
else
    pushd ${TMP_DIR}
        curl -L -O https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
        unzip consul_${CONSUL_VERSION}_linux_amd64.zip
    popd
fi
mv -v ${TMPDIR}/consul ${CONTAINER_PATH}/usr/local/bin/consul
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/consul
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 consul.service

buildah config --volume /var/lib/consul ${CONTAINER_UUID}

commit_container consul:latest
