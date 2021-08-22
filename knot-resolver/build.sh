. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/systemd:$(date +'%Y.%m.%d')-1
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

dnf_install "knot-resolver knot-resolver-module-dnstap knot-resolver-module-http"

dnf_clean
dnf_clean_cache

buildah run -t ${CONTAINER_UUID} systemctl enable\
 kresd@1.service

clean_files

buildah commit ${CONTAINER_UUID} ${REGISTRY}/knot-resolver:$(date +'%Y.%m.%d')-1
buildah rm -a
