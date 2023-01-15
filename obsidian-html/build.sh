#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create base/python3 ${1}

buildah run --network=host ${CONTAINER_UUID} pip3 install $(jq -r .[0].name ./files/versions.json)==$(jq -r .[0].version ./files/versions.json)

rm -vrf ${CONTAINER_PATH}/root/.cache

container_commit base/obsidian-html ${IMAGE_TAG}
