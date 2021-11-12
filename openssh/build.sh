. ../meta/functions.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
    dnf_install "openssh-server openssh-clients"
    rm -v ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
else
    dnf_install "openssh-server openssh-clients"
fi

dnf_clean
dnf_clean_cache

sed -i 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/' ${CONTAINER_PATH}/etc/pam.d/sshd

buildah run -t ${CONTAINER_UUID} systemctl unmask\
 systemd-logind.service

buildah run -t ${CONTAINER_UUID} systemctl enable\
 sshd.service

clean_files

commit_container openssh:latest
