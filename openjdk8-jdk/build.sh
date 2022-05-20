. ../meta/common.sh

CONTAINER_UUID=$(create_container base/openjdk8-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "java-1.8.0-openjdk-devel maven maven-openjdk8"
dnf_clean_cache
dnf_clean

commit_container base/openjdk8-jdk:latest
