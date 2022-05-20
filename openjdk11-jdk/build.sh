. ../meta/common.sh

CONTAINER_UUID=$(create_container base/openjdk11-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "java-11-openjdk-devel maven maven-openjdk11"
dnf_clean_cache
dnf_clean

commit_container base/openjdk11-jdk:latest
