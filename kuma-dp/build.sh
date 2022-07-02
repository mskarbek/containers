#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://download.konghq.com/mesh-alpine/kuma-${KUMA_VERSION}-rhel-amd64.tar.gz|tar xzv
popd
mv -v ${TMP_DIR}/kuma-${KUMA_VERSION}/bin/{kuma-dp,envoy,coredns} ${CONTAINER_PATH}/usr/local/bin/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{kuma-dp,envoy,coredns}
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} groupadd\
 --gid=996\
 --system\
 kuma
buildah run --network none ${CONTAINER_UUID} useradd\
 --comment="Kuma"\
 --home-dir=/run/kuma\
 --no-create-home\
 --gid=996\
 --uid=996\
 --shell=/usr/sbin/nologin\
 --system\
 kuma
buildah run --network none ${CONTAINER_UUID} systemctl enable\
 kuma-dp.service

buildah config --volume /etc/kuma ${CONTAINER_UUID}
buildah config --volume /var/log/kuma ${CONTAINER_UUID}

container_commit base/kuma-dp ${IMAGE_TAG}


container_create base/kuma-dp ${1}

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

container_commit kuma-dp ${IMAGE_TAG}
