#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create base ${1}

dnf_cache
if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
    dnf_copr "enable mskarbek/dinit"
    dnf_copr "enable mskarbek/tinyproxy"
fi
dnf_install "dinit tinyproxy"
dnf_install "iproute iproute-tc iputils nftables iptables-nft ipset"
dnf_install "openssh-clients bind-utils sudo passwd bash-completion findutils"
dnf_install "podman-remote git-core rsync vim-enhanced nano fish ansible htop tmux jq tree ncdu"
dnf_install "rpm dnf subscription-manager"
dnf_cache_clean
dnf_clean

rsync_rootfs_all

buildah run --network none ${CONTAINER_UUID} useradd -c "Ansible" -m ansible

container_commit wsl ${IMAGE_TAG}
