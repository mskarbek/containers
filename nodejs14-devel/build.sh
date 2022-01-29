. ../meta/common.sh

CONTAINER_UUID=$(create_container base/nodejs14:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "git-core tar unzip gzip make gcc gcc-c++"
dnf_clean_cache
dnf_clean

commit_container base/nodejs14-devel:latest
