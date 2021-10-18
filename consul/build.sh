. ../meta/functions.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

CONSUL_VERSION="1.10.3"

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cp -v files/consul ${CONTAINER_PATH}/usr/local/bin/consul
else
    TMPDIR=$(mktemp -d)
    pushd ${TMPDIR}
        curl -L -O https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
        unzip consul_${CONSUL_VERSION}_linux_amd64.zip
    popd
    mv -v ${TMPDIR}/consul ${CONTAINER_PATH}/usr/local/bin/consul
    rm -rf ${TMPDIR}
fi

chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/consul

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 consul.service

commit_container consul:latest
