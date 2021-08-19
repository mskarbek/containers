. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/bootstrap/base:$(date +'%Y.%m.%d')-1
else
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/base:$(date +'%Y.%m.%d')-1
fi

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/systemd:$(date +'%Y.%m.%d')-1
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/systemd:$(date +'%Y.%m.%d')-1
fi
buildah rm -a
