. ../meta/functions.sh

CONTAINER_ID=$(buildah from ${REGISTRY}/systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_ID})

ln -s /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/host.repo

dnf -y\
 --installroot=${CONTAINER_PATH}\
 --releasever=8.4\
 --setopt=module_platform_id=platform:el8\
 --setopt=install_weak_deps=false\
 --nodocs\
 module enable redis:6

dnf_install "redis"

dnf_clean

buildah run -t ${CONTAINER_ID} systemctl enable\
 redis.service

clean_files

buildah commit ${CONTAINER_ID} ${REGISTRY}/redis:latest
buildah rm -a
