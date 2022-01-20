. ../meta/common.sh

CONTAINER_UUID=$(create_container base:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    dnf_install "java-17-openjdk-headless"
else
    dnf_install "java-17-openjdk-headless tomcat-native apr"
fi
dnf_clean_cache
dnf_clean

commit_container base/openjdk17-jre:latest


CONTAINER_UUID=$(create_container base/openjdk17-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}

commit_container openjdk17-jre:latest
