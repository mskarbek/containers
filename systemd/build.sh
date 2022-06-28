#!/usr/bin/env bash
set -e

source ../meta/common.sh

container_create base ${1}

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

container_commit systemd $IMAGE_TAG
