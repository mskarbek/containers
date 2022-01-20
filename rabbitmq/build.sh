. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/rabbitmq.repo ${CONTAINER_PATH}/etc/yum.repos.d/rabbitmq.repo
    cp -v ./files/RPM-GPG-KEY-rabbitmq /etc/pki/rpm-gpg/RPM-GPG-KEY-rabbitmq
    dnf_install "erlang rabbitmq-server"
else
    dnf_install "erlang rabbitmq-server"
fi
dnf_clean_cache
dnf_clean

buildah run -t ${CONTAINER_UUID} systemctl enable\
 rabbitmq-config.service\
 rabbitmq-server.service

buildah config --volume /var/lib/rabbitmq ${CONTAINER_UUID}

commit_container rabbitmq:latest
