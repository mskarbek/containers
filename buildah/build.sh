. ../meta/functions.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cat << EOF > ${CONTAINER_PATH}/etc/yum.repos.d/beta.repo
[rhel-8-beta-for-x86_64-baseos-rpms]
name=Red Hat Enterprise Linux 8 Beta for x86_64 - BaseOS (RPMs)
baseurl=file:///mnt/BaseOS/
enabled=1
gpgcheck=0

[rhel-8-beta-for-x86_64-appstream-rpms]
name=Red Hat Enterprise Linux 8 Beta for x86_64 - AppStream (RPMs)
baseurl=file:///mnt/AppStream/
enabled=1
gpgcheck=0
EOF
    dnf_install "buildah skopeo git-core rsync zfs"
    rm -f ${CONTAINER_PATH}/etc/yum.repos.d/beta.repo
else
    dnf_install "buildah skopeo git-core rsync zfs"
fi

dnf_clean
dnf_clean_cache

clean_files

#sed -i 's/#mount_program = "\/usr\/bin\/fuse-overlayfs"/mount_program = "\/usr\/bin\/fuse-overlayfs"/' ${CONTAINER_PATH}/etc/containers/storage.conf
sed -i 's/driver = "overlay"/driver = "zfs"/' ${CONTAINER_PATH}/etc/containers/storage.conf

buildah run -t ${CONTAINER_UUID} systemctl mask\
 zfs.target\
 zfs-import.target\
 zfs-volumes.target

commit_container buildah:latest
