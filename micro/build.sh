. ../meta/common.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} scratch
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_install "--disablerepo=* --enablerepo=rhel-8-for-x86_64-baseos-rpms glibc-minimal-langpack coreutils-single ca-certificates"
dnf_clean

if [ -f ./files/proxy.repo ] && [ -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/proxy.repo ${CONTAINER_PATH}/etc/yum.repos.d/proxy.repo
    sed -i "s/REPOSITORY_URL/${REPOSITORY_URL}/g" ${CONTAINER_PATH}/etc/yum.repos.d/proxy.repo
fi

if [ -f ./files/*.pem ]; then
    cp -v ./files/*.pem ${CONTAINER_PATH}/etc/pki/ca-trust/source/anchors/
fi

buildah run -t ${CONTAINER_UUID} update-ca-trust
buildah config --env='container=oci' ${CONTAINER_UUID}
buildah config --cmd='[ "/usr/bin/bash" ]' ${CONTAINER_UUID}

commit_container micro:latest
