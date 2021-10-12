. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/base:latest
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

dnf_module "enable nodejs:14"

dnf_install "nodejs npm"

dnf_clean
dnf_clean_cache

clean_files

buildah commit ${CONTAINER_UUID} ${REGISTRY}/base/nodejs14:latest
buildah rm -a


CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/base/nodejs14:latest

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}

buildah commit ${CONTAINER_UUID} ${REGISTRY}/nodejs14:latest
buildah rm -a
