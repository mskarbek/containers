. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/base:$(date +'%Y.%m.%d')-1
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

copy_repo

dnf_install "java-1.8.0-openjdk-headless tomcat-native apr"

dnf_clean

clean_files

buildah commit ${CONTAINER_UUID} ${REGISTRY}/base/openjdk8-jre:$(date +'%Y.%m.%d')-1
buildah rm -a


CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/base/openjdk8-jre:$(date +'%Y.%m.%d')-1

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}

buildah commit ${CONTAINER_UUID} ${REGISTRY}/openjdk8-jre:$(date +'%Y.%m.%d')-1
buildah rm -a
