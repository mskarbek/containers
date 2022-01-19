. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container openjdk8-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ -f ./files/fake-service ]; then
    cp -v ./files/fake-service ${CONTAINER_PATH}/usr/local/bin/fake-service
else
    TMP_DIR=$(mktemp -d)
    pushd ${TMP_DIR}
        curl -L -O https://github.com/nicholasjackson/fake-service/releases/download/v${FAKE_SERVICE_VERSION}/fake_service_linux_amd64.zip
        unzip ./fake_service_linux_amd64.zip
        mv -v ./fake-service ${CONTAINER_PATH}/usr/local/bin/fake-service
    popd
    rm -rfv ${TMP_DIR}
fi
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/fake-service

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 fake-service.service

buildah config --volume /etc/fake-service ${CONTAINER_UUID}

commit_container fake-service:latest
