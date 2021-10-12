. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} scratch
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_install "glibc-minimal-langpack coreutils-single"

rsync_rootfs

#sed -i "s/<REPO>/${REPO}/" ${CONTAINER_PATH}/etc/yum.repos.d/proxy.repo

# TODO: for some unknow reason `info` scriptlet for post-installation s(t)ucks if instaled in one transaction with above packages
# need to debug and fix to drop multiple dnf_install instances in script
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    rm -v ${CONTAINER_PATH}/etc/yum.repos.d/proxy.repo
    cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
    dnf_install "ca-certificates"
else
    dnf_install "ca-certificates"
fi

dnf_clean
buildah run -t ${CONTAINER_UUID} update-ca-trust

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    rm -v ${CONTAINER_PATH}/etc/yum.repos.d/*.repo
fi
clean_files

buildah config --cmd '[ "/usr/bin/bash" ]' ${CONTAINER_UUID}

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/micro:latest
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/micro:latest
fi
buildah rm -a
