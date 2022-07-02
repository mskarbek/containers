#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create base ${1}

dnf_cache
dnf_install "git gcc gcc-c++ clang llvm rpm-build"
dnf_cache_clean
dnf_clean

container_commit base/rpmbuild ${IMAGE_TAG}
