#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create base ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L -O https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
popd
mv -v ${TMP_DIR}/terraform ${CONTAINER_PATH}/usr/local/bin/terraform
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/terraform
rm -vrf ${TMP_DIR}

container_commit base/terraform ${IMAGE_TAG}
