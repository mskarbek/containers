. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} scratch
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_install "glibc-minimal-langpack coreutils-single"
# TODO: for some unknow reason `info` scriptlet for post-installation s(t)ucks if instaled in one transaction with above packages
# need to debug and fix to drop multiple dnf_install instances in script
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
    dnf_install "ca-certificates"
else
    dnf_install "ca-certificates"
fi

dnf_clean

rsync_rootfs

buildah run -t ${CONTAINER_UUID} update-ca-trust

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    rm -v ${CONTAINER_PATH}/etc/yum.repos.d/*.repo
fi
clean_files

buildah config --cmd '[ "/usr/bin/bash" ]' ${CONTAINER_UUID}

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/micro:$(date +'%Y.%m.%d')-1
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/micro:$(date +'%Y.%m.%d')-1
fi
buildah rm -a
