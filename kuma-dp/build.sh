. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/systemd:latest
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMPDIR=$(mktemp -d)
pushd ${TMPDIR}
curl -L https://download.konghq.com/mesh-alpine/kuma-1.2.1-rhel-amd64.tar.gz|tar xzv
popd

mv -v ${TMPDIR}/kuma*/bin/kuma-dp ${CONTAINER_PATH}/usr/local/bin/
mv -v ${TMPDIR}/kuma*/bin/envoy ${CONTAINER_PATH}/usr/local/bin/
mv -v ${TMPDIR}/kuma*/bin/coredns ${CONTAINER_PATH}/usr/local/bin/

rm -rf ${TMPDIR} 

chown -v root:root ${CONTAINER_PATH}/usr/local/bin/*
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/*

mkdir ${CONTAINER_PATH}/var/lib/kuma

rsync -hrvP --ignore-existing rootfs/ ${CONTAINER_PATH}/

buildah run -t ${CONTAINER_UUID} systemctl enable kuma-dp.service

buildah commit ${CONTAINER_UUID} ${REGISTRY}/kuma-dp:latest
buildah rm -a
