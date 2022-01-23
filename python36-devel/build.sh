. ../meta/common.sh

CONTAINER_UUID=$(create_container base/python36:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "python3-devel libffi-devel gcc make"
dnf_clean_cache
dnf_clean

commit_container base/python36-devel:latest
