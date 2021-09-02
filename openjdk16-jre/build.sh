. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/base:$(date +'%Y.%m.%d')-1
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

dnf_install "java-latest-openjdk-headless tomcat-native apr"

dnf_clean
dnf_clean_cache

clean_files

buildah commit ${CONTAINER_UUID} ${REGISTRY}/base/openjdk16-jre:$(date +'%Y.%m.%d')-1
buildah rm -a


CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/base/openjdk16-jre:$(date +'%Y.%m.%d')-1

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}

buildah commit ${CONTAINER_UUID} ${REGISTRY}/openjdk16-jre:$(date +'%Y.%m.%d')-1
buildah rm -a
