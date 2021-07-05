REGISTRY='10.88.0.1:8082'

CONTAINER_ID=$(buildah from scratch)
CONTAINER_PATH=$(buildah mount ${CONTAINER_ID})

dnf -y\
 --disablerepo=*\
 --enablerepo=rhel-8-for-x86_64-baseos-rpms\
 --enablerepo=rhel-8-for-x86_64-appstream-rpms\
 --installroot=${CONTAINER_PATH}\
 --releasever=8.4\
 --setopt=module_platform_id=platform:el8\
 --setopt=install_weak_deps=false\
 --nodocs\
 install glibc-minimal-langpack coreutils-single
dnf -y\
 --installroot=${CONTAINER_PATH}\
 --releasever=8.4\
 clean all

#rsync -hrvP --ignore-existing rootfs/ ${CONTAINER_PATH}/
#chown -Rv root:root ${CONTAINER_PATH}/ect/pki/ca-cert/*
#find ${CONTAINER_ID}/ -type f -exec chmod -v 0755 {} \;

#buildah run -t ${CONTAINER_ID} update-ca-trust

rm -rvf\
 ${CONTAINER_PATH}/var/cache/*\
 ${CONTAINER_PATH}/var/log/dnf*\
 ${CONTAINER_PATH}/var/log/yum*\
 ${CONTAINER_PATH}/var/log/hawkey*\
 ${CONTAINER_PATH}/var/log/rhsm

buildah config --cmd '[ "/usr/bin/bash" ]' ${CONTAINER_ID}

buildah commit ${CONTAINER_ID} ${REGISTRY}/micro:$(date +'%Y.%m.%d')-1
buildah rm -a

