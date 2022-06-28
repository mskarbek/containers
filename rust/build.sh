#!/usr/bin/env bash
set -e

source ../meta/common.sh

container_create base ${1}

dnf_cache
dnf_install "rust cargo"
dnf_cache_clean
dnf_clean

container_commit base/rust ${IMAGE_TAG}
