#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create openssh ${1}

dnf_cache
dnf_install "python3 python3-pip python3-setuptools python3-wheel python3-pip-wheel python3-setuptools-wheel"
dnf_install "ansible-core git-core rsync python3-requests python3-certifi python3-idna python3-charset-normalizer python3-wcwidth python3-pbr python3-attrs python3-urllib3 python3-prettytable"
dnf_cache_clean
dnf_clean

buildah run ${CONTAINER_UUID} pip3 install ara==${ARA_VERSION} python-consul

rm -vrf ${CONTAINER_PATH}/root/.cache

curl -L -o ${CONTAINER_PATH}/usr/local/bin/mcli https://dl.min.io/client/mc/release/linux-amd64/archive/mc.${MCLI_VERSION}
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/mcli

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://download.konghq.com/mesh-alpine/kuma-${KUMA_VERSION}-rhel-amd64.tar.gz|tar xzv
popd
mv -v ${TMP_DIR}/kuma-${KUMA_VERSION}/bin/kumactl ${CONTAINER_PATH}/usr/local/bin/kumactl
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/kumactl
rm -vrf ${TMP_DIR}

rsync_rootfs
buildah run --workingdir /var/lib/rundeck ${CONTAINER_UUID} ansible-galaxy collection install -r .ansible/requirements.yaml -p .ansible/collections
buildah config --volume /var/lib/rundeck/.ssh ${CONTAINER_UUID}

container_commit rundeck-runner ${IMAGE_TAG}
