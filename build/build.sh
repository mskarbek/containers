. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/base:latest
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

dnf_install "git gcc gcc-c++ clang llvm rpm-build"

dnf_clean
dnf_clean_cache

clean_files

buildah commit ${CONTAINER_UUID} ${REGISTRY}/build:latest
buildah rm -a
