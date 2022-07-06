#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create openssh ${1}

if [ -z ${GITLAB_TYPE} ] || [ ${GITLAB_TYPE} != "ee" ]; then
    GITLAB_TYPE="ce"
fi

dnf_cache
if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
    cp -v ./files/gitlab-${GITLAB_TYPE}.repo /etc/yum.repos.d/gitlab-${GITLAB_TYPE}.repo
    cp -v ./files/gitlab-${GITLAB_TYPE}.repo ${CONTAINER_PATH}/etc/yum.repos.d/gitlab-${GITLAB_TYPE}.repo
fi
dnf_install "hostname perl policycoreutils policycoreutils-python-utils checkpolicy git libxcrypt-compat"
TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    dnf download gitlab-${GITLAB_TYPE}-${GITALB_VERSION}
popd
rpm -ivh --noscripts --root=${CONTAINER_PATH} ${TMP_DIR}/gitlab-${GITLAB_TYPE}-${GITALB_VERSION}-*.el8.x86_64.rpm
rm -vrf ${TMP_DIR}
dnf_cache_clean
dnf_clean

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 gitlab-config.service

buildah config --volume /etc/gitlab ${CONTAINER_UUID}
buildah config --volume /var/log/gitlab ${CONTAINER_UUID}
buildah config --volume /var/opt/gitlab ${CONTAINER_UUID}

container_commit gitlab ${IMAGE_TAG}
