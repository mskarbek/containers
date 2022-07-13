#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create base ${1}

dnf_cache
dnf_install "--allowerasing coreutils git gcc gcc-c++ clang llvm libtool which rpm-build dnf dnf-plugins-core yum-utils bzip2 cpio diffutils findutils gawk grep gzip info patch redhat-rpm-config sed shadow-utils tar unzip util-linux xz"
dnf_cache_clean
dnf_clean

container_commit base/rpmbuild ${IMAGE_TAG}
