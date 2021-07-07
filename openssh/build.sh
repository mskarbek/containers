. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/systemd:$(date +'%Y.%m.%d')-1
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

copy_repo

dnf_install "openssh-server openssh-clients rsync"

dnf_clean

buildah run -t ${CONTAINER_UUID} systemctl unmask\
 systemd-logind.service

clean_files

buildah commit ${CONTAINER_UUID} ${REGISTRY}/openssh:$(date +'%Y.%m.%d')-1
buildah rm -a
