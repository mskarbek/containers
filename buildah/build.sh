. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/bootstrap/openssh:$(date +'%Y.%m.%d')-1
else
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/openssh:$(date +'%Y.%m.%d')-1
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
    dnf_install "buildah git-core rsync"
else
    dnf_install "buildah git-core rsync zfs"
fi

dnf_clean
dnf_clean_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    rm -v ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
else
    buildah run -t ${CONTAINER_UUID} systemctl mask\
     zfs.target\
     zfs-import.target\
     zfs-volumes.target
fi

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    sed -i 's/#mount_program = "\/usr\/bin\/fuse-overlayfs"/mount_program = "\/usr\/bin\/fuse-overlayfs"/' ${CONTAINER_PATH}/etc/containers/storage.conf
else
    sed -i 's/driver = "overlay"/driver = "zfs"/' ${CONTAINER_PATH}/etc/containers/storage.conf
fi

clean_files

buildah config --volume /var/lib/containers ${CONTAINER_UUID}

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/buildah:$(date +'%Y.%m.%d')-1
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/buildah:$(date +'%Y.%m.%d')-1
fi
buildah rm -a
