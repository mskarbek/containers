. ../meta/common.sh

CONTAINER_UUID=$(create_container base/openjdk17-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_module "enable maven:3.6"
dnf_install "java-17-openjdk-devel java-11-openjdk-headless maven maven-openjdk11"
dnf_clean_cache
dnf_clean

commit_container base/openjdk17-jdk:latest
