. ../meta/common.sh

CONTAINER_UUID=$(create_container openssh:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "sudo less findutils curl vi hostname iputils iproute tar unzip zstd gzip rsync openssh-clients dnf NetworkManager"
dnf_clean_cache
dnf_clean

commit_container host:latest
