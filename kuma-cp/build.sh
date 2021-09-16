. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/systemd:$(date +'%Y.%m.%d')-1
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMPDIR=$(mktemp -d)
pushd ${TMPDIR}
curl -L https://download.konghq.com/mesh-alpine/kuma-1.2.1-rhel-amd64.tar.gz|tar xzv
popd

mv -v ${TMPDIR}/kuma*/bin/kuma-cp ${CONTAINER_PATH}/usr/local/bin/

rm -rf ${TMPDIR}

chown -v root:root ${CONTAINER_PATH}/usr/local/bin/*
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/*

mkdir ${CONTAINER_PATH}/var/lib/kuma

rsync -hrvP --ignore-existing rootfs/ ${CONTAINER_PATH}/

buildah run -t ${CONTAINER_UUID} systemctl enable kuma-cp.service

buildah commit ${CONTAINER_UUID} ${REGISTRY}/kuma-cp:$(date +'%Y.%m.%d')-1
buildah rm -a
