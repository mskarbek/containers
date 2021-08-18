. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} scratch
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_install "glibc-minimal-langpack coreutils-single ca-certificates"

dnf_clean

rsync_rootfs

buildah run -t ${CONTAINER_UUID} update-ca-trust

clean_files

buildah config --cmd '[ "/usr/bin/bash" ]' ${CONTAINER_UUID}

buildah commit ${CONTAINER_UUID} ${REGISTRY}/micro:$(date +'%Y.%m.%d')-1
buildah rm -a
