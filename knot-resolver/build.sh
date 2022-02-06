. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "knot-resolver knot-resolver-module-dnstap knot-resolver-module-http"
dnf_clean_cache
dnf_clean

mkdir -vp ${CONTAINER_PATH}/usr/share/knot-resolver
mv -v ${CONTAINER_PATH}/etc/knot-resolver/* ${CONTAINER_PATH}/usr/share/knot-resolver
rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 kresd@1.service

buildah config --volume /etc/knot-resolver ${CONTAINER_UUID}

commit_container knot-resolver:latest
