#!/usr/bin/env bash
set -e

source ../meta/common.sh

container_create base/python3 ${1}

rsync_rootfs

dnf_cache
dnf_install "ansible-core git-core openssh-clients podman-remote python3-attrs python3-boto3 python3-botocore python3-certifi python3-charset-normalizer python3-dns python3-idna python3-pbr python3-prettytable python3-psycopg2 python3-psycopg3 python3-requests python3-urllib3 python3-wcwidth rsync"
dnf_cache_clean
dnf_clean

buildah run --network=host ${CONTAINER_UUID} pip3 install ara==$(jq -r .[0].version ./files/versions.json) python-consul hvac
#buildah run --network=none ${CONTAINER_UUID} podman-remote system connection add -d host unix:///run/podman/podman.sock
buildah run --network=none ${CONTAINER_UUID} ln -s /usr/bin/podman-remote /usr/bin/podman

VERSION=$(jq -r .[1].version ./files/versions.json)
PWD_DIR=$(pwd)
TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
        curl -L -O $(jq -r .[1].remote_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g")
    else
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -O $(jq -r .[1].local_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
    fi
    unzip ./$(jq -r .[1].file_name ${PWD_DIR}/files/versions.json | sed "s;VERSION;${VERSION};")
popd
mv -v ${TMP_DIR}/terraform ${CONTAINER_PATH}/usr/local/bin/terraform
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/terraform
rm -vrf ${TMP_DIR}

mkdir -vp ${CONTAINER_PATH}/usr/local/share/terraform/plugins

rm -vrf ${CONTAINER_PATH}/root/.cache

if [ ! -z $CI_HTTP_PROXY ]; then
    buildah run --network=host --workingdir=/root --env HTTP_PROXY=${CI_HTTP_PROXY} --env HTTPS_PROXY=${CI_HTTP_PROXY} ${CONTAINER_UUID} ansible-galaxy collection install -r .ansible/requirements.yaml -p .ansible/collections
else
    buildah run --network=host --workingdir=/root ${CONTAINER_UUID} ansible-galaxy collection install -r .ansible/requirements.yaml -p .ansible/collections
fi

container_commit base/automation ${IMAGE_TAG}
