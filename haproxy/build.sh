. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "haproxy"
dnf_clean_cache
dnf_clean

buildah run -t ${CONTAINER_UUID} systemctl enable\
 haproxy.service

buildah config --volume /etc/haproxy ${CONTAINER_UUID}

commit_container haproxy:latest
