. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/bootstrap/base:$(date +'%Y.%m.%d')-1
else
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/base:$(date +'%Y.%m.%d')-1
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
    dnf_install "java-11-openjdk-headless"
else
    dnf_install "java-11-openjdk-headless tomcat-native apr"
fi

dnf_clean
dnf_clean_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    rm -v ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
fi

clean_files

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/base/openjdk11-jre:$(date +'%Y.%m.%d')-1
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/base/openjdk11-jre:$(date +'%Y.%m.%d')-1
fi
buildah rm -a


CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/bootstrap/base/openjdk11-jre:$(date +'%Y.%m.%d')-1
else
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/base/openjdk11-jre:$(date +'%Y.%m.%d')-1
fi

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/openjdk11-jre:$(date +'%Y.%m.%d')-1
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/openjdk11-jre:$(date +'%Y.%m.%d')-1
fi
buildah rm -a
