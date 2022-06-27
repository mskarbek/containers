. ../meta/common.sh

if [ -z ${1} ]; then
    CONTAINER_UUID=$(create_container systemd latest)
else
    CONTAINER_UUID=$(create_container systemd ${1})
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/vector.repo ${CONTAINER_PATH}/etc/yum.repos.d/vector.repo
    cp -v ./files/RPM-GPG-KEY-vector /etc/pki/rpm-gpg/RPM-GPG-KEY-vector
fi

dnf_cache
dnf_install "vector"
dnf_clean_cache
dnf_clean

mkdir -v ${CONTAINER_PATH}/usr/share/vector
mv -v ${CONTAINER_PATH}/etc/vector/* ${CONTAINER_PATH}/usr/share/vector/

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 vector.service
 
buildah config --volume /etc/vector ${CONTAINER_UUID}
buildah config --volume /var/lib/vector ${CONTAINER_UUID}

commit_container vector ${IMAGE_TAG}
