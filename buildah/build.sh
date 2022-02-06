. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "buildah skopeo rsync dnf"
dnf_clean_cache
dnf_clean

mkdir -vp /var/lib/volumes/storage
cp -v ${CONTAINER_PATH}/usr/share/containers/containers.conf ${CONTAINER_PATH}/etc/containers/containers.conf
sed -i 's/^# volume_path = .*/volume_path = "\/var\/lib\/volumes\/storage"/' ${CONTAINER_PATH}/etc/containers/containers.conf

buildah config --volume /var/lib/containers/storage ${CONTAINER_UUID}

commit_container buildah:latest
