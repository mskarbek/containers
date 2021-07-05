. ../meta/functions.sh

CONTAINER_ID=$(buildah from ${REGISTRY}/systemd:$(date +'%Y.%m.%d')-1)
CONTAINER_PATH=$(buildah mount ${CONTAINER_ID})

ln -s /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/host.repo

dnf_install "openssh-server openssh-clients rsync"

dnf_clean

buildah run -t ${CONTAINER_ID} systemctl unmask\
 systemd-logind.service

clean_files

buildah commit ${CONTAINER_ID} ${REGISTRY}/openssh:$(date +'%Y.%m.%d')-1
buildah rm -a
