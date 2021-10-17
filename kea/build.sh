. ../meta/functions.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
fi

cp -v ./files/*.repo ${CONTAINER_PATH}/etc/yum.repos.d/
cp -v ./files/RPM-GPG-KEY-* ${CONTAINER_PATH}/etc/pki/rpm-gpg/

dnf_install "isc-kea isc-stork-agent"

dnf_clean
dnf_clean_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    rm -v ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
fi

buildah run -t ${CONTAINER_UUID} systemctl enable\
 isc-kea-dhcp4.service
# isc-stork-agent.service

clean_files

commit_container kea:latest
