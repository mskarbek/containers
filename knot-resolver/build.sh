. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/epel.repo ${CONTAINER_PATH}/etc/yum.repos.d/epel.repo
    cp -v ./files/RPM-GPG-KEY-EPEL-8 /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
fi

dnf_cache
dnf_install "knot-resolver knot-resolver-module-dnstap knot-resolver-module-http"
dnf_clean_cache
dnf_clean

buildah run -t ${CONTAINER_UUID} systemctl enable\
 kresd@1.service

commit_container knot-resolver:latest
