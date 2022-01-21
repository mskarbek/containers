. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/grafana.repo ${CONTAINER_PATH}/etc/yum.repos.d/grafana.repo
    cp -v ./files/RPM-GPG-KEY-grafana /etc/pki/rpm-gpg/RPM-GPG-KEY-grafana
    dnf_install "grafana"
else
    dnf_install "grafana"
fi
dnf_clean_cache
dnf_clean

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 grafana-server.service

buildah config --volume /etc/grafana ${CONTAINER_UUID}
buildah config --volume /var/lib/grafana ${CONTAINER_UUID}
buildah config --volume /var/log/grafana ${CONTAINER_UUID}

commit_container grafana:latest

