#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create openssh ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/pgdg-redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/pgdg-redhat.repo
fi
cp -v ./files/RPM-GPG-KEY-PGDG ${CONTAINER_PATH}/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG
rpm --import --root=${CONTAINER_PATH} ./files/RPM-GPG-KEY-PGDG
dnf_install_with_docs "bash-completion"
dnf_install "sudo less findutils curl vi nano telnet hostname iputils iproute mtr tmux lsof knot-utils tar unzip zstd gzip rsync jq htop openssh-clients tcpdump postgresql14"
dnf_cache_clean
dnf_clean

curl -L -o ./files/yq https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64
cp -v ./files/yq ${CONTAINER_PATH}/usr/local/bin/yq
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/yq

rsync_rootfs

buildah run ${CONTAINER_UUID} useradd --comment "ToolBox" --create-home --shell /usr/bin/bash toolbox

buildah config --volume /home/toolbox/.ssh ${CONTAINER_UUID}

container_commit toolbox ${IMAGE_TAG}


CONTAINER_UUID=$(create_container toolbox ${IMAGE_TAG})
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

buildah config --cmd '[ "/usr/bin/bash" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGINT' ${CONTAINER_UUID}
buildah config --volume - ${CONTAINER_UUID}
buildah config --user toolbox ${CONTAINER_UUID}
buildah config --workingdir /home/toolbox ${CONTAINER_UUID}

container_commit base/toolbox ${IMAGE_TAG}
