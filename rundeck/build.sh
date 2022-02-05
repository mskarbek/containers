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

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 rundeckd.service

commit_container rundeck:latest
