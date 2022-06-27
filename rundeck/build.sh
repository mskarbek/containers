. ../meta/common.sh

if [ -z ${1} ]; then
    CONTAINER_UUID=$(create_container openjdk11-jre latest)
else
    CONTAINER_UUID=$(create_container openjdk11-jre ${1})
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/rundeck.repo ${CONTAINER_PATH}/etc/yum.repos.d/rundeck.repo
    cp -v ./files/RPM-GPG-KEY-rundeck /etc/pki/rpm-gpg/RPM-GPG-KEY-rundeck
fi

dnf_cache
dnf_install "rundeck git-core"
dnf_clean_cache
dnf_clean

ln -s $(ls -1 ${CONTAINER_PATH}/var/lib/rundeck/bootstrap) ${CONTAINER_PATH}/var/lib/rundeck/bootstrap/rundeck.war

#mkdir -vp ${CONTAINER_PATH}/usr/share/rundeck
#mv -v ${CONTAINER_PATH}/etc/rundeck/* ${CONTAINER_PATH}/usr/share/rundeck/
rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 rundeckd.service

#buildah config --volume /etc/rundeck ${CONTAINER_UUID}
buildah config --volume /var/log/rundeck ${CONTAINER_UUID}

commit_container rundeck ${IMAGE_TAG}
