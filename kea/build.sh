. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/*.repo ${CONTAINER_PATH}/etc/yum.repos.d/
    cp -v ./files/RPM-GPG-KEY-* /etc/pki/rpm-gpg/
fi

dnf_cache
dnf_install "isc-kea isc-stork-agent"
dnf_clean_cache
dnf_clean

mkdir -v ${CONTAINER_PATH}/usr/share/kea/etc
mv -v ${CONTAINER_PATH}/etc/kea/* ${CONTAINER_PATH}/usr/share/kea/etc/

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 kea-dhcp4.service
# isc-stork-agent.service

buildah config --volume /etc/kea ${CONTAINER_UUID}

commit_container kea:latest
