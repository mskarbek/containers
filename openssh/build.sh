. ../meta/common.sh

if [ -z ${1} ]; then
    CONTAINER_UUID=$(create_container systemd latest)
else
    CONTAINER_UUID=$(create_container systemd ${1})
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

buildah run --network none ${CONTAINER_UUID} systemctl unmask\
 systemd-logind.service

dnf_cache
dnf_install "openssh-server openssh-clients"
dnf_clean_cache
dnf_clean

for FILE in {sshd,remote,login,systemd-user}; do
    sed -i 's/session[ \t]*required[ \t]*pam_loginuid.so/#session    required     pam_loginuid.so/' ${CONTAINER_PATH}/etc/pam.d/${FILE}
done

rsync_rootfs

commit_container openssh ${IMAGE_TAG}
