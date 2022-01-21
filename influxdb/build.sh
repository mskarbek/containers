. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/influxdb.repo ${CONTAINER_PATH}/etc/yum.repos.d/influxdb.repo
    cp -v ./files/RPM-GPG-KEY-influxdb /etc/pki/rpm-gpg/RPM-GPG-KEY-influxdb
    dnf_install "influxdb2"
else
    dnf_install "influxdb2"
fi
dnf_clean_cache
dnf_clean

mv -v ${CONTAINER_PATH}/etc/influxdb/config.toml ${CONTAINER_PATH}/usr/share/influxdb/
rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 influxdb.service

buildah config --volume /etc/influxdb ${CONTAINER_UUID}
buildah config --volume /var/lib/influxdb ${CONTAINER_UUID}

commit_container influxdb:latest
