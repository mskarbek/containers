. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "buildah skopeo rsync dnf"
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    if [ ! -f ./files/libnvpair3-${ZFS_VERSION}-1.el8.x86_64.rpm ] || [ ! -f ./files/libuutil3-${ZFS_VERSION}-1.el8.x86_64.rpm ] || [ ! -f ./files/libzfs5-${ZFS_VERSION}-1.el8.x86_64.rpm ] || [ ! -f ./files/libzpool5-${ZFS_VERSION}-1.el8.x86_64.rpm ] || [ ! -f ./files/zfs-${ZFS_VERSION}-1.el8.x86_64.rpm ] || [ ! -f ./files/zfs-container-${ZFS_VERSION}-1.el8.noarch.rpm ]; then
        pushd ./files
            curl -L -O https://github.com/zeet-cc/zfs-rpms/releases/download/v${ZFS_VERSION}-rhel8.5/libnvpair3-${ZFS_VERSION}-1.el8.x86_64.rpm
            curl -L -O https://github.com/zeet-cc/zfs-rpms/releases/download/v${ZFS_VERSION}-rhel8.5/libuutil3-${ZFS_VERSION}-1.el8.x86_64.rpm
            curl -L -O https://github.com/zeet-cc/zfs-rpms/releases/download/v${ZFS_VERSION}-rhel8.5/libzfs5-${ZFS_VERSION}-1.el8.x86_64.rpm
            curl -L -O https://github.com/zeet-cc/zfs-rpms/releases/download/v${ZFS_VERSION}-rhel8.5/libzpool5-${ZFS_VERSION}-1.el8.x86_64.rpm
            curl -L -O https://github.com/zeet-cc/zfs-rpms/releases/download/v${ZFS_VERSION}-rhel8.5/zfs-${ZFS_VERSION}-1.el8.x86_64.rpm
            curl -L -O https://github.com/zeet-cc/zfs-rpms/releases/download/v${ZFS_VERSION}-rhel8.5/zfs-container-${ZFS_VERSION}-1.el8.noarch.rpm
        popd
    fi
    dnf_install "./files/libnvpair3-${ZFS_VERSION}-1.el8.x86_64.rpm ./files/libuutil3-${ZFS_VERSION}-1.el8.x86_64.rpm ./files/libzfs5-${ZFS_VERSION}-1.el8.x86_64.rpm ./files/libzpool5-${ZFS_VERSION}-1.el8.x86_64.rpm ./files/zfs-${ZFS_VERSION}-1.el8.x86_64.rpm ./files/zfs-container-${ZFS_VERSION}-1.el8.noarch.rpm"
else
    dnf_install "zfs zfs-container"
fi
dnf_clean_cache
dnf_clean

cp -v ${CONTAINER_PATH}/usr/share/containers/containers.conf ${CONTAINER_PATH}/etc/containers/containers.conf
sed -i 's/^# volume_path = .*/volume_path = "\/var\/lib\/volumes\/storage"/' ${CONTAINER_PATH}/etc/containers/containers.conf
sed -i 's/^driver = .*/driver = "zfs"/' ${CONTAINER_PATH}/etc/containers/storage.conf

buildah run -t ${CONTAINER_UUID} systemctl mask\
 zfs-import-cache.service\
 zfs-import-scan.service\
 zfs-import.service\
 zfs-import.target\
 zfs-mount.service\
 zfs-share.service\
 zfs-volume-wait.service\
 zfs-volumes.target\
 zfs-zed.service\
 zfs.target

buildah config --volume /var/lib/containers/storage ${CONTAINER_UUID}

commit_container buildah:latest
