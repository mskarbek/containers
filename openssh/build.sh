. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/bootstrap/systemd:latest
else
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/systemd:latest
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
fi

dnf_install "openssh-server openssh-clients"

dnf_clean
dnf_clean_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    rm -v ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
fi

buildah run -t ${CONTAINER_UUID} systemctl unmask\
 systemd-logind.service

sed -i 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/' ${CONTAINER_PATH}/etc/pam.d/sshd

clean_files

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/openssh:latest
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/openssh:latest
fi
buildah rm -a
