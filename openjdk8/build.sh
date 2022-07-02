#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create base ${1}

dnf_cache
dnf_install "java-1.8.0-openjdk-headless apr"
# tomcat-native - not in EPEL 9 yet
dnf_cache_clean
dnf_clean

container_commit base/openjdk8-jre ${IMAGE_TAG}


container_create base/openjdk8-jre ${IMAGE_TAG}

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

container_commit openjdk8-jre ${IMAGE_TAG}


container_create base/openjdk8-jre ${IMAGE_TAG}

dnf_cache
dnf_install "java-1.8.0-openjdk-devel maven maven-openjdk8"
dnf_cache_clean
dnf_clean

container_commit base/openjdk8-jdk ${IMAGE_TAG}
