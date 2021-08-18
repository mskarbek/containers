. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/base:$(date +'%Y.%m.%d')-1
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
    dnf_install "java-1.8.0-openjdk-headless"
else
    dnf_install "java-1.8.0-openjdk-headless tomcat-native apr"
fi

dnf_clean

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    rm -v ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
fi

clean_files

buildah commit ${CONTAINER_UUID} ${REGISTRY}/base/openjdk8-jre:$(date +'%Y.%m.%d')-1
buildah rm -a


CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/base/openjdk8-jre:$(date +'%Y.%m.%d')-1

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}

buildah commit ${CONTAINER_UUID} ${REGISTRY}/openjdk8-jre:$(date +'%Y.%m.%d')-1
buildah rm -a
