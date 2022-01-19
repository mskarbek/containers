. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

buildah run -t ${CONTAINER_UUID} systemctl unmask\
 systemd-logind.service

dnf_cache
dnf_install "openssh-server openssh-clients"
dnf_clean_cache
dnf_clean

for FILE in {sshd,remote,login,systemd-user}; do
    sed -i 's/session[ \t]*required[ \t]*pam_loginuid.so/#session    required     pam_loginuid.so/' ${CONTAINER_PATH}/etc/pam.d/${FILE}
done

rsync_rootfs

commit_container openssh:latest
