. ../meta/functions.sh

CONTAINER_ID=$(buildah from ${REGISTRY}/systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_ID})

ln -s /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/host.repo

dnf_install "mysql-server hostname"

dnf_clean

buildah run -t ${CONTAINER_ID} systemctl enable\
 mysqld.service

clean_files

buildah commit ${CONTAINER_ID} ${REGISTRY}/mysql:latest
buildah rm -a
