. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "vsftpd passwd"
dnf_clean_cache
dnf_clean

rm -vf ${CONTAINER_PATH}/usr/share/nginx/html/index.html
touch ${CONTAINER_PATH}/usr/share/nginx/html/index.html

buildah run -t ${CONTAINER_UUID} systemctl enable\
 vsftpd.service

commit_container vsftpd:latest
