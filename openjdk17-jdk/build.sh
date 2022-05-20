. ../meta/common.sh

CONTAINER_UUID=$(create_container base/openjdk17-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "java-17-openjdk-devel maven maven-openjdk17"
dnf_clean_cache
dnf_clean

commit_container base/openjdk17-jdk:latest
