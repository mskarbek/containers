. ../meta/common.sh
. ./files/VERSIONS

if [ -z ${1} ]; then
    CONTAINER_UUID=$(create_container systemd latest)
else
    CONTAINER_UUID=$(create_container systemd ${1})
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "buildah skopeo fuse-overlayfs netavark iputils iproute iptables-nft rsync dnf dnf-plugins-core tar"
dnf_clean_cache
dnf_clean

sed -i 's/^#mount_program = .*/mount_program = "\/usr\/bin\/fuse-overlayfs"/' ${CONTAINER_PATH}/etc/containers/storage.conf

cp -v ${CONTAINER_PATH}/usr/share/containers/containers.conf ${CONTAINER_PATH}/etc/containers/containers.conf
sed -i 's/^# volume_path = .*/volume_path = "\/var\/lib\/volumes"/' ${CONTAINER_PATH}/etc/containers/containers.conf
sed -i 's/^#network_backend = .*/network_backend = "netavark"/' ${CONTAINER_PATH}/etc/containers/containers.conf
sed -i 's/^#default_network = .*/default_network = "ci"/' ${CONTAINER_PATH}/etc/containers/containers.conf

mkdir -vp /var/lib/volumes

buildah config --volume /var/lib/containers ${CONTAINER_UUID}

commit_container buildah ${IMAGE_TAG}


CONTAINER_UUID=$(create_container buildah ${IMAGE_TAG})
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    TMP_DIR=$(mktemp -d)
    pushd ${TMP_DIR}
        curl -L -O https://github.com/zeet-cc/zfs-rpms/releases/download/v${ZFS_VERSION}-rhel9.0/libnvpair3-${ZFS_VERSION}-1.el9.x86_64.rpm
        curl -L -O https://github.com/zeet-cc/zfs-rpms/releases/download/v${ZFS_VERSION}-rhel9.0/libuutil3-${ZFS_VERSION}-1.el9.x86_64.rpm
        curl -L -O https://github.com/zeet-cc/zfs-rpms/releases/download/v${ZFS_VERSION}-rhel9.0/libzfs5-${ZFS_VERSION}-1.el9.x86_64.rpm
        curl -L -O https://github.com/zeet-cc/zfs-rpms/releases/download/v${ZFS_VERSION}-rhel9.0/libzpool5-${ZFS_VERSION}-1.el9.x86_64.rpm
        curl -L -O https://github.com/zeet-cc/zfs-rpms/releases/download/v${ZFS_VERSION}-rhel9.0/zfs-${ZFS_VERSION}-1.el9.x86_64.rpm
        curl -L -O https://github.com/zeet-cc/zfs-rpms/releases/download/v${ZFS_VERSION}-rhel9.0/zfs-container-${ZFS_VERSION}-1.el9.noarch.rpm
        dnf_install "./libnvpair3-${ZFS_VERSION}-1.el9.x86_64.rpm ./libuutil3-${ZFS_VERSION}-1.el9.x86_64.rpm ./libzfs5-${ZFS_VERSION}-1.el9.x86_64.rpm ./libzpool5-${ZFS_VERSION}-1.el9.x86_64.rpm ./zfs-${ZFS_VERSION}-1.el9.x86_64.rpm ./zfs-container-${ZFS_VERSION}-1.el9.noarch.rpm"
    popd
    rm -rf ${TMP_DIR}
else
    dnf_install "zfs zfs-container"
fi
dnf_clean_cache
dnf_clean

sed -i 's/^driver = .*/driver = "zfs"/' ${CONTAINER_PATH}/etc/containers/storage.conf

buildah run --network none ${CONTAINER_UUID} systemctl mask\
 zfs-import-cache.service\
 zfs-import-scan.service\
 zfs-import.service\
 zfs-import.target\
 zfs-mount.service\
 zfs-share.service\
 zfs-volume-wait.service\
 zfs-volumes.target\
 zfs-zed.service\
 zfs.target\
 sysstat.service\
 sysstat-collect.timer\
 sysstat-summary.timer

commit_container buildah-zfs ${IMAGE_TAG}
