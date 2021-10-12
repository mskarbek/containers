. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/bootstrap/base:latest
else
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/base:latest
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
fi

dnf_install "nano iputils iproute mtr htop tmux lsof"

dnf_clean
dnf_clean_cache

clean_files

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    rm -v ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
fi

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/base/toolbox:latest
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/base/toolbox:latest
fi
buildah rm -a


CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/bootstrap/base/toolbox:latest
else
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/base/toolbox:latest
fi

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/toolbox:latest
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/toolbox:latest
fi
buildah rm -a
