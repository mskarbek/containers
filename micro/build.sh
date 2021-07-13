. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} scratch
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_install "glibc-minimal-langpack coreutils-single"

dnf_clean

clean_repos

rsync_rootfs

#chown -Rv root:root ${CONTAINER_PATH}/ect/pki/ca-cert/*
#find ${CONTAINER_UUID}/ -type f -exec chmod -v 0755 {} \;

#buildah run -t ${CONTAINER_UUID} update-ca-trust

clean_files

buildah config --cmd '[ "/usr/bin/bash" ]' ${CONTAINER_UUID}

buildah commit ${CONTAINER_UUID} ${REGISTRY}/micro:$(date +'%Y.%m.%d')-1
buildah rm -a
