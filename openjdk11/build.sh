#!/usr/bin/env bash
set -e

source ../meta/common.sh

container_create base ${1}

dnf_cache
dnf_install "java-11-openjdk-headless apr"
# tomcat-native - not in EPEL 9 yet
dnf_cache_clean
dnf_clean

container_commit base/openjdk11-jre ${IMAGE_TAG}


container_create base/openjdk11-jre ${IMAGE_TAG}

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

container_commit openjdk11-jre ${IMAGE_TAG}


container_create base/openjdk11-jre ${IMAGE_TAG}

dnf_cache
dnf_install "java-11-openjdk-devel maven maven-openjdk11"
dnf_cache_clean
dnf_clean

container_commit base/openjdk11-jdk ${IMAGE_TAG}
