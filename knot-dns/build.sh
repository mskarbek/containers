. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/epel.repo ${CONTAINER_PATH}/etc/yum.repos.d/epel.repo
    cp -v ./files/RPM-GPG-KEY-EPEL-8 /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
fi

dnf_cache
dnf_install "knot knot-module-dnstap knot-utils"
dnf_clean_cache
dnf_clean

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 knot.service

buildah config --volume /etc/knot ${CONTAINER_UUID}
buildah config --volume /var/lib/knot ${CONTAINER_UUID}

commit_container knot-dns:latest
