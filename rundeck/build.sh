. ../meta/common.sh

CONTAINER_UUID=$(create_container openjdk11-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/rundeck.repo ${CONTAINER_PATH}/etc/yum.repos.d/rundeck.repo
    cp -v ./files/RPM-GPG-KEY-rundeck /etc/pki/rpm-gpg/RPM-GPG-KEY-rundeck
fi

dnf_cache
dnf_install "rundeck git-core"
dnf_clean_cache
dnf_clean

#mkdir -vp ${CONTAINER_PATH}/usr/share/rundeck
#mv -v ${CONTAINER_PATH}/etc/rundeck/* ${CONTAINER_PATH}/usr/share/rundeck/
rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 rundeckd.service

#buildah config --volume /etc/rundeck ${CONTAINER_UUID}
buildah config --volume /var/log/rundeck ${CONTAINER_UUID}

commit_container rundeck:latest
