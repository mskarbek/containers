. ../meta/common.sh

CONTAINER_UUID=$(create_container base:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_module "enable nodejs:14"
dnf_install "nodejs npm tar unzip git-core gzip"
dnf_clean_cache
dnf_clean

commit_container base/nodejs14:latest
