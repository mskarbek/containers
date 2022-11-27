#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create base ${1}

VERSION=$(jq -r .[0].version ./files/versions.json)
PWD_DIR=$(pwd)
TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
        curl -L $(jq -r .[0].remote_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g") | tar xzv
    else
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L $(jq -r .[0].local_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};") | tar xzv
    fi
popd
mv -v ${TMP_DIR}/kuma-${VERSION}/bin/{kuma-dp,envoy,coredns} ${CONTAINER_PATH}/usr/local/bin/
mv -v ${TMP_DIR}/kuma-${VERSION}/ebpf/{mb_bind,mb_connect,mb_get_sockopts,mb_recvmsg,mb_redir,mb_sendmsg,mb_sockops,mb_tc} ${CONTAINER_PATH}/usr/local/libexec/
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/{kuma-dp,envoy,coredns}
chmod -v 0755 ${CONTAINER_PATH}/usr/local/libexec/{mb_bind,mb_connect,mb_get_sockopts,mb_recvmsg,mb_redir,mb_sendmsg,mb_sockops,mb_tc}
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

buildah config --volume /etc/kuma ${CONTAINER_UUID}
buildah config --volume /var/log/kuma ${CONTAINER_UUID}

container_commit base/kuma-dp ${IMAGE_TAG}


container_create base/kuma-dp ${1}

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 kuma-dp.service

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

container_commit kuma-dp ${IMAGE_TAG}
