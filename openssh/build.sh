. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/systemd:$(date +'%Y.%m.%d')-1
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

dnf_install "openssh-server openssh-clients"

dnf_clean

buildah run -t ${CONTAINER_UUID} systemctl unmask\
 systemd-logind.service

clean_files

sed -i 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/' ${CONTAINER_PATH}/etc/pam.d/sshd

buildah commit ${CONTAINER_UUID} ${REGISTRY}/openssh:$(date +'%Y.%m.%d')-1
buildah rm -a
