#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create openssh ${1}

dnf_cache
dnf_install "sudo less findutils curl vi hostname iputils iproute tar unzip zstd gzip rsync openssh-clients dnf NetworkManager git-core"
dnf_cache_clean
dnf_clean

container_commit host ${IMAGE_TAG}
