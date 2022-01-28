. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/couchdb.repo ${CONTAINER_PATH}/etc/yum.repos.d/couchdb.repo
    cp -v ./files/RPM-GPG-KEY-couchdb /etc/pki/rpm-gpg/RPM-GPG-KEY-couchdb
    dnf_install "couchdb"
else
    dnf_install "couchdb"
fi
dnf_clean_cache
dnf_clean

buildah run -t ${CONTAINER_UUID} systemctl enable\
 couchdb.service
 
buildah config --volume /var/lib/couchdb ${CONTAINER_UUID}
buildah config --volume /var/log/couchdb ${CONTAINER_UUID}

commit_container couchdb:latest
