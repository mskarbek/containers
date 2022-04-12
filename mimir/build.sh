. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ -f ./files/metaconvert ] && [ -f ./files/mimir ] && [ -f ./files/mimirtool ] && [ -f ./files/query-tee ]; then
    cp -v ./files/{metaconvert,mimir,mimirtool,query-tee} ${CONTAINER_PATH}/usr/local/bin/
else
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/metaconvert https://github.com/grafana/mimir/releases/download/mimir-${MIMIR_VERSION}/metaconvert-linux-amd64
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/mimir https://github.com/grafana/mimir/releases/download/mimir-${MIMIR_VERSION}/mimir-linux-amd64
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/mimirtool https://github.com/grafana/mimir/releases/download/mimir-${MIMIR_VERSION}/mimirtool-linux-amd64
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/query-tee https://github.com/grafana/mimir/releases/download/mimir-${MIMIR_VERSION}/query-tee-linux-amd64
fi
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{metaconvert,mimir,mimirtool,query-tee}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 mimir.service

buildah config --volume /etc/mimir ${CONTAINER_UUID}
buildah config --volume /var/lib/mimir ${CONTAINER_UUID}

commit_container mimir:latest
