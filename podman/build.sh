. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "podman skopeo rsync"
dnf_clean_cache
dnf_clean

cp -v ${CONTAINER_PATH}/usr/share/containers/containers.conf ${CONTAINER_PATH}/etc/containers/containers.conf
sed -i 's/^# volume_path = .*/volume_path = "\/var\/lib\/volumes"/' ${CONTAINER_PATH}/etc/containers/containers.conf

buildah run -t ${CONTAINER_UUID} systemctl enable\
 podman.socket

buildah config --volume /var/lib/containers ${CONTAINER_UUID}
buildah config --volume /var/lib/volumes ${CONTAINER_UUID}

commit_container podman:latest
