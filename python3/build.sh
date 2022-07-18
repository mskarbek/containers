#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create base ${1}

dnf_cache
dnf_install "python3 python3-pip python3-setuptools python3-wheel python3-pip-wheel python3-setuptools-wheel"
dnf_cache_clean
dnf_clean

if [ ${IMAGE_BOOTSTRAP} != "true" ]; then
    cat << EOF > ${CONTAINER_PATH}/etc/pip.conf
[global]
trusted-host = ${REPOSITORY_PIP_TRUSTED_HOST}
index = ${REPOSITORY_PIP_INDEX}
index-url = ${REPOSITORY_PIP_INDEX_URL}
EOF
    cat << EOF > ${CONTAINER_PATH}/root/.netrc
machine ${REPOSITORY_PIP_TRUSTED_HOST}
    login ${REPOSITORY_USERNAME}
    password ${REPOSITORY_PASSWORD}
EOF
    chmod -v 0600 ${CONTAINER_PATH}/root/.netrc
fi

container_commit base/python3 ${IMAGE_TAG}


container_create base/python3 ${IMAGE_TAG}

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

container_commit python3 ${IMAGE_TAG}


container_create base/python3 ${IMAGE_TAG}

dnf_cache
dnf_install "python3-devel libffi-devel gcc make"
dnf_cache_clean
dnf_clean

container_commit base/python3-devel ${IMAGE_TAG}
