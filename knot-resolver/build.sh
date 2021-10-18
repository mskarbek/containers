. ../meta/functions.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
fi

cp -v ./files/epel.repo ${CONTAINER_PATH}/etc/yum.repos.d/epel.repo

dnf_cache

dnf_install "knot-resolver knot-resolver-module-dnstap knot-resolver-module-http"

dnf_clean
dnf_clean_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    rm -v ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
fi

buildah run -t ${CONTAINER_UUID} systemctl enable\
 kresd@1.service

clean_files

commit_container knot-resolver:latest
