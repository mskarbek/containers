. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm"
dnf_install "--enablerepo=codeready-builder-for-rhel-9-x86_64-rpms https://github.com/mskarbek/guacamole-rpm/releases/download/v1.4.0-rhel9.0/guacamole-server-1.4.0-1.el9.x86_64.rpm https://github.com/mskarbek/guacamole-rpm/releases/download/v1.4.0-rhel9.0/guacamole-server-vnc-1.4.0-1.el9.x86_64.rpm https://github.com/mskarbek/guacamole-rpm/releases/download/v1.4.0-rhel9.0/guacamole-server-rdp-1.4.0-1.el9.x86_64.rpm"
dnf_clean_cache
dnf_clean

#rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 guacd.service

buildah config --volume /etc/guacamole ${CONTAINER_UUID}

commit_container gnome:latest
