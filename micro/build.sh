. ../meta/common.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} scratch
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ${BASE_OS} = "el8" ]; then
    ENABLE_REPO="rhel-8-for-x86_64-baseos-rpms"
elif [ ${BASE_OS} = "c8s" ]; then
    ENABLE_REPO="baseos"
else
    printf "ERROR: Missing or incorrect BASE_OS variable." >&2
    exit 1
fi

dnf_install "--disablerepo=* --enablerepo=${ENABLE_REPO} glibc-minimal-langpack coreutils-single"
dnf_install "--disablerepo=* --enablerepo=${ENABLE_REPO} ca-certificates"
dnf_clean

if [ -f ./files/proxy.repo ] && [ -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/proxy.repo ${CONTAINER_PATH}/etc/yum.repos.d/proxy.repo
    sed -i "s/REPOSITORY_URL/${REPOSITORY_URL}/g" ${CONTAINER_PATH}/etc/yum.repos.d/proxy.repo
fi

if [ -f ./files/*.pem ]; then
    cp -v ./files/*.pem ${CONTAINER_PATH}/etc/pki/ca-trust/source/anchors/
    buildah run -t ${CONTAINER_UUID} update-ca-trust
fi

buildah config --env='container=oci' ${CONTAINER_UUID}
buildah config --cmd='[ "/usr/bin/bash" ]' ${CONTAINER_UUID}

commit_container micro:latest
