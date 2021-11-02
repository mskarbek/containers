. ../meta/functions.sh

CONTAINER_UUID=$(create_container base/openjdk11-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
    dnf_module "enable maven:3.6"
    dnf_install "java-11-openjdk-devel maven maven-openjdk11"
    rm -v ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
else
    dnf_module "enable maven:3.6"
    dnf_install "java-11-openjdk-devel maven maven-openjdk11"
fi

dnf_clean
dnf_clean_cache

clean_files

commit_container base/openjdk11-jdk:latest


CONTAINER_UUID=$(create_container base/openjdk11-jdk:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}

commit_container openjdk11-jdk:latest
