#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
dnf_install "findutils dnf diffutils iputils iproute"
dnf_cache_clean
dnf_clean

container_commit full ${IMAGE_TAG}
