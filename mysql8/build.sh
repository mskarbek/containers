. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "policycoreutils rsync tar gettext hostname bind-utils groff-base mysql-server"
dnf_clean_cache
dnf_clean

rsync_rootfs

buildah run -t ${CONTAINER_UUID} setcap -r /usr/libexec/mysqld
buildah run -t ${CONTAINER_UUID} systemctl enable\
 mysqld.service

buildah config --volume /var/lib/mysql ${CONTAINER_UUID}
#buildah config --volume /var/log/mysql ${CONTAINER_UUID}

commit_container mysql8:latest
