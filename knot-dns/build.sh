. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/systemd:latest
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

dnf_install "knot knot-module-dnstap"

dnf_clean
dnf_clean_cache

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 knot.service

clean_files

buildah config --volume /var/lib/knot ${CONTAINER_UUID}

buildah commit ${CONTAINER_UUID} ${REGISTRY}/knot-dns:latest
buildah rm -a
