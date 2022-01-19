. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/krakend.repo ${CONTAINER_PATH}/etc/yum.repos.d/krakend.repo
    cp -v ./files/RPM-GPG-KEY-krakend /etc/pki/rpm-gpg/RPM-GPG-KEY-krakend
    dnf_install "krakend"
else
    dnf_install "krakend"
fi
dnf_clean_cache
dnf_clean

buildah config --volume /etc/krakend ${CONTAINER_UUID}
buildah run -t ${CONTAINER_UUID} usermod -d /run/krakend krakend
buildah run -t ${CONTAINER_UUID} systemctl enable\
 krakend.service

commit_container krakend:latest
