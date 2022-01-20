. ../meta/common.sh

CONTAINER_UUID=$(create_container base/openjdk17-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    if [ ! -f ./files/maven-3.6.2-7.module_el8.6.0+1031+e2e9e02c.noarch.rpm ] || [ ! -f ./files/maven-lib-3.6.2-7.module_el8.6.0+1031+e2e9e02c.noarch.rpm ] || [ ! -f ./files/maven-openjdk17-3.6.2-7.module_el8.6.0+1031+e2e9e02c.noarch.rpm ]; then
        pushd ./files
            curl -L -O https://koji.mbox.centos.org/pkgs/packages/maven/3.6.2/7.module_el8.6.0+1031+e2e9e02c/noarch/maven-3.6.2-7.module_el8.6.0+1031+e2e9e02c.noarch.rpm
            curl -L -O https://koji.mbox.centos.org/pkgs/packages/maven/3.6.2/7.module_el8.6.0+1031+e2e9e02c/noarch/maven-lib-3.6.2-7.module_el8.6.0+1031+e2e9e02c.noarch.rpm
            curl -L -O https://koji.mbox.centos.org/pkgs/packages/maven/3.6.2/7.module_el8.6.0+1031+e2e9e02c/noarch/maven-openjdk17-3.6.2-7.module_el8.6.0+1031+e2e9e02c.noarch.rpm
        popd
    fi
    dnf_module "enable maven:3.6"
    dnf_install "java-17-openjdk-devel ./files/maven-3.6.2-7.module_el8.6.0+1031+e2e9e02c.noarch.rpm ./files/maven-lib-3.6.2-7.module_el8.6.0+1031+e2e9e02c.noarch.rpm ./files/maven-openjdk17-3.6.2-7.module_el8.6.0+1031+e2e9e02c.noarch.rpm --exclude=java-1.8.0-openjdk-headless"
else
    dnf_module "enable maven:3.6"
    dnf_install "java-17-openjdk-devel maven maven-openjdk17 --exclude=java-1.8.0-openjdk-headless"
fi
dnf_clean_cache
dnf_clean

commit_container base/openjdk17-jdk:latest
