. ../meta/common.sh

CONTAINER_UUID=$(create_container openjdk11-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/rundeck.repo ${CONTAINER_PATH}/etc/yum.repos.d/rundeck.repo
    cp -v ./files/RPM-GPG-KEY-rundeck /etc/pki/rpm-gpg/RPM-GPG-KEY-rundeck
    dnf_install "rundeck git-core"
else
    dnf_install "rundeck git-core"
fi
dnf_clean_cache
dnf_clean

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 rundeck.service

commit_container rundeck:latest
