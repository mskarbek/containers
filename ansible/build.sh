. ../meta/common.sh

CONTAINER_UUID=$(create_container base:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "ansible openssh-clients git-core rsync"
dnf_clean_cache
dnf_clean

commit_container base/ansible:latest
