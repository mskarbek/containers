. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ -f ./files/haproxy-2.4.7-1.el8.x86_64.rpm ] && [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    dnf_install "./files/haproxy-2.4.7-1.el8.x86_64.rpm"
elif [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    dnf_install "https://download.copr.fedorainfracloud.org/results/mskarbek/epel-ext/epel-8-x86_64/03293308-haproxy/haproxy-2.4.7-1.el8.x86_64.rpm"
else
    dnf_install "haproxy"
fi
dnf_clean_cache
dnf_clean

mv ${CONTAINER_PATH}/etc/haproxy/haproxy.cfg ${CONTAINER_PATH}/usr/share/haproxy/

buildah run -t ${CONTAINER_UUID} systemctl enable\
 haproxy.service

buildah config --volume /etc/haproxy ${CONTAINER_UUID}

commit_container haproxy:latest
