#!/usr/bin/env bash
set -e

source ../meta/common.sh

container_create base/python3 ${1}

dnf_cache
dnf_install "ansible-core openssh-clients git-core rsync python3-requests python3-certifi python3-idna python3-charset-normalizer python3-wcwidth python3-pbr python3-attrs python3-urllib3 python3-prettytable python3-botocore python3-boto3 podman-remote"
dnf_cache_clean
dnf_clean

buildah run --network=host ${CONTAINER_UUID} pip3 install ara==$(jq -r .[0].version ./files/versions.json) python-consul
buildah run --network=none ${CONTAINER_UUID} podman-remote system connection add -d host unix:///run/podman/podman.sock
buildah run --network=none ${CONTAINER_UUID} ln -s /usr/bin/podman-remote /usr/bin/podman

rm -vrf ${CONTAINER_PATH}/root/.cache

rsync_rootfs

if [ ! -z $CI_HTTP_PROXY ]; then
    buildah run --network=host --workingdir /root --env HTTP_PROXY=${CI_HTTP_PROXY} --env HTTPS_PROXY=${CI_HTTP_PROXY} ${CONTAINER_UUID} ansible-galaxy collection install -r .ansible/requirements.yaml -p .ansible/collections
else
    buildah run --network=host --workingdir /root ${CONTAINER_UUID} ansible-galaxy collection install -r .ansible/requirements.yaml -p .ansible/collections
fi

container_commit base/ansible ${IMAGE_TAG}
