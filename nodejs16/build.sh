. ../meta/common.sh

CONTAINER_UUID=$(create_container base:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_module "enable nodejs:16"
dnf_install "nodejs npm"
dnf_clean_cache
dnf_clean

commit_container base/nodejs16:latest
