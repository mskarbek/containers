. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "libstdc++ git-core hostname bash-completion openssh-clients"
dnf_clean_cache
dnf_clean


TMP_DIR=$(mktemp -d)
if [ -f "./files/openvscode-server-v${OPENVSCODE_VERSION}-linux-x64.tar.gz" ]; then
    tar xvf ./files/openvscode-server-v${OPENVSCODE_VERSION}-linux-x64.tar.gz -C ${TMP_DIR}
else
    pushd ${TMP_DIR}
        curl -L https://github.com/gitpod-io/openvscode-server/releases/download/openvscode-server-v${OPENVSCODE_VERSION}/openvscode-server-v${OPENVSCODE_VERSION}-linux-x64.tar.gz|tar xzv
    popd
fi
mv -v ${TMP_DIR}/openvscode-server-v${OPENVSCODE_VERSION}-linux-x64 ${CONTAINER_PATH}/usr/lib/openvscode
rm -rf ${TMP_DIR}

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 openvscode.service

buildah config --volume /home/openvscode ${CONTAINER_UUID}

commit_container openvscode:latest
