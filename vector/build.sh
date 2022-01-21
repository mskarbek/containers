. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/vector.repo ${CONTAINER_PATH}/etc/yum.repos.d/vector.repo
    cp -v ./files/RPM-GPG-KEY-vector /etc/pki/rpm-gpg/RPM-GPG-KEY-vector
    dnf_install "vector"
else
    dnf_install "vector"
fi
dnf_clean_cache
dnf_clean

mkdir -v ${CONTAINER_PATH}/usr/share/vector
mv -v ${CONTAINER_PATH}/etc/vector/* ${CONTAINER_PATH}/usr/share/vector/

buildah run -t ${CONTAINER_UUID} systemctl enable\
 vector.service
 
buildah config --volume /etc/vector ${CONTAINER_UUID}
buildah config --volume /var/lib/vector ${CONTAINER_UUID}

commit_container vector:latest
