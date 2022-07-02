#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create base ${1}

dnf_cache
dnf_install "nodejs npm"
dnf_cache_clean
dnf_clean

container_commit base/nodejs16 ${IMAGE_TAG}


container_create base/nodejs16 ${IMAGE_TAG}

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

container_commit nodejs16 ${IMAGE_TAG}


container_create base/nodejs16 ${IMAGE_TAG}

dnf_cache
dnf_install "git-core tar unzip gzip make gcc gcc-c++"
dnf_cache_clean
dnf_clean

container_commit base/nodejs16-devel ${IMAGE_TAG}
