. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ -f ./files/tinyproxy-1.11.0-1.el8.x86_64.rpm ] && [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    dnf_install "./files/tinyproxy-1.11.0-1.el8.x86_64.rpm"
elif [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    dnf_install "https://download.copr.fedorainfracloud.org/results/mskarbek/tinyproxy/epel-8-x86_64/02320604-tinyproxy/tinyproxy-1.11.0-1.el8.x86_64.rpm"
else
    dnf_install "tinyproxy"
fi
dnf_clean_cache
dnf_clean

buildah run -t ${CONTAINER_UUID} systemctl enable\
 tinyproxy.service

buildah config --volume /etc/tinyproxy ${CONTAINER_UUID}

commit_container tinyproxy:latest
