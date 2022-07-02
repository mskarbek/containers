#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
dnf_install "redis"
dnf_cache_clean
dnf_clean

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 redis.service

container_commit redis ${IMAGE_TAG}
