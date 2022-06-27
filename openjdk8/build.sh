. ../meta/common.sh

if [ -z ${1} ]; then
    CONTAINER_UUID=$(create_container base latest)
else
    CONTAINER_UUID=$(create_container base ${1})
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "java-1.8.0-openjdk-headless apr"
# tomcat-native - not in EPEL 9 yet
dnf_clean_cache
dnf_clean

commit_container base/openjdk8-jre ${IMAGE_TAG}


CONTAINER_UUID=$(create_container base/openjdk8-jre ${IMAGE_TAG})
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

commit_container openjdk8-jre ${IMAGE_TAG}


CONTAINER_UUID=$(create_container base/openjdk8-jre ${IMAGE_TAG})
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "java-1.8.0-openjdk-devel maven maven-openjdk8"
dnf_clean_cache
dnf_clean

commit_container base/openjdk8-jdk ${IMAGE_TAG}
