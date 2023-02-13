#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create base ${1}

dnf_cache
dnf_install "php uwsgi-plugin-php"
dnf_cache_clean
dnf_clean

container_commit base/php8 ${IMAGE_TAG}


container_create base/php8 ${IMAGE_TAG}

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

container_commit php8 ${IMAGE_TAG}


#container_create base/php8 ${IMAGE_TAG}
#
#dnf_cache
#dnf_install "php8-devel libffi-devel gcc make"
#dnf_cache_clean
#dnf_clean
#
#container_commit base/php8-devel ${IMAGE_TAG}
