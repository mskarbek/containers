. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/openjdk8-jre:latest
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

copy_repo

rsync_rootfs
cp rootfs/etc/pki/rpm-gpg/RPM-GPG-KEY-rundeck /etc/pki/rpm-gpg/RPM-GPG-KEY-rundeck

dnf_install "rundeck git-core"

dnf_clean

clean_files

#buildah run -t ${CONTAINER_UUID} systemctl enable\
# rundeck.service

buildah commit ${CONTAINER_UUID} ${REGISTRY}/rundeck:latest
buildah rm -a
