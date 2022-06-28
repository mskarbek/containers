#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

dnf_cache
dnf_install "libstdc++ git-core hostname bash-completion openssh-clients"
dnf_cache_clean
dnf_clean


TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://github.com/gitpod-io/openvscode-server/releases/download/openvscode-server-v${OPENVSCODE_VERSION}/openvscode-server-v${OPENVSCODE_VERSION}-linux-x64.tar.gz|tar xzv
popd
mv -v ${TMP_DIR}/openvscode-server-v${OPENVSCODE_VERSION}-linux-x64 ${CONTAINER_PATH}/usr/lib/openvscode
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 openvscode.service

buildah config --volume /home/openvscode ${CONTAINER_UUID}

container_commit openvscode ${IMAGE_TAG}
