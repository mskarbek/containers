. ../meta/common.sh

CONTAINER_UUID=$(create_container base:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "curl vi nano telnet iputils iproute mtr tmux lsof"
dnf_clean_cache
dnf_clean

commit_container base/toolbox:latest


CONTAINER_UUID=$(create_container openssh:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "curl vi nano telnet iputils iproute mtr tmux lsof"
dnf_clean_cache
dnf_clean

commit_container toolbox:latest
