. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/powerdns.repo ${CONTAINER_PATH}/etc/yum.repos.d/
    cp -v ./files/RPM-GPG-KEY-powerdns /etc/pki/rpm-gpg/
fi

dnf_cache
dnf_install "pdns pdns-tools sqlite"
dnf_install_with_docs "pdns-backend-sqlite"
dnf_clean_cache
dnf_clean

rsync_rootfs
mv -v ${CONTAINER_PATH}/etc/pdns/pdns.conf ${CONTAINER_PATH}/usr/share/pdns/pdns.conf.example

buildah run -t ${CONTAINER_UUID} systemctl enable\
 pdns.service

buildah config --volume /etc/pdns ${CONTAINER_UUID}
buildah config --volume /var/lib/pdns ${CONTAINER_UUID}

commit_container powerdns:latest
