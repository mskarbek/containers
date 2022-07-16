#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create base/python3 ${1}

dnf_cache
dnf_install "ansible-core openssh-clients git-core rsync python3-requests python3-certifi python3-idna python3-charset-normalizer python3-wcwidth python3-pbr python3-attrs python3-urllib3 python3-prettytable python3-botocore python3-boto3"
dnf_cache_clean
dnf_clean

buildah run ${CONTAINER_UUID} pip3 install ara==${ARA_VERSION} python-consul

rm -vrf ${CONTAINER_PATH}/root/.cache

rsync_rootfs
buildah run --workingdir /root ${CONTAINER_UUID} ansible-galaxy collection install -r .ansible/requirements.yaml -p .ansible/collections

container_commit base/ansible ${IMAGE_TAG}
