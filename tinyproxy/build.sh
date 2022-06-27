. ../meta/common.sh

if [ -z ${1} ]; then
    CONTAINER_UUID=$(create_container systemd latest)
else
    CONTAINER_UUID=$(create_container systemd ${1})
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    dnf_install "https://download.copr.fedorainfracloud.org/results/mskarbek/tinyproxy/epel-9-x86_64/04426720-tinyproxy/tinyproxy-1.11.0-1.el9.x86_64.rpm"
else
    dnf_install "tinyproxy"
fi
dnf_clean_cache
dnf_clean

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 tinyproxy.service

buildah config --volume /etc/tinyproxy ${CONTAINER_UUID}

commit_container tinyproxy ${IMAGE_TAG}
