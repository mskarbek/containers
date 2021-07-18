. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/systemd:$(date +'%Y.%m.%d')-1
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_install "knot knot-module-dnstap"

dnf_clean

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 knot.service

clean_files

buildah config --volume /var/lib/knot ${CONTAINER_UUID}

buildah commit ${CONTAINER_UUID} ${REGISTRY}/knot-dns:$(date +'%Y.%m.%d')-1
buildah rm -a
