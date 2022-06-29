#!/usr/bin/env bash
set -e

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/rabbitmq.repo ${CONTAINER_PATH}/etc/yum.repos.d/rabbitmq.repo
fi
dnf_install "erlang rabbitmq-server"
dnf_cache_clean
dnf_clean

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 rabbitmq-password.service\
 rabbitmq-config.service\
 rabbitmq-server.service

buildah config --volume /etc/rabbitmq ${CONTAINER_UUID}
buildah config --volume /var/lib/rabbitmq ${CONTAINER_UUID}
buildah config --volume /var/log/rabbitmq ${CONTAINER_UUID}

container_commit rabbitmq ${IMAGE_TAG}
