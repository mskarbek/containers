#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create base ${1}

dnf_cache
dnf_install "java-17-openjdk-headless apr tomcat-native"
dnf_cache_clean
dnf_clean

container_commit base/openjdk17-jre ${IMAGE_TAG}


container_create base/openjdk17-jre ${IMAGE_TAG}

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

container_commit openjdk17-jre ${IMAGE_TAG}


container_create base/openjdk17-jre ${IMAGE_TAG}

dnf_cache
dnf_module "enable maven:3.8"
dnf_install "java-17-openjdk-devel maven maven-openjdk17"
dnf_cache_clean
dnf_clean

container_commit base/openjdk17-jdk ${IMAGE_TAG}
