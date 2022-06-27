. ../meta/common.sh
. ./files/VERSIONS

if [ -z ${1} ]; then
    CONTAINER_UUID=$(create_container openssh latest)
else
    CONTAINER_UUID=$(create_container openssh ${1})
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/pgdg-redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/pgdg-redhat.repo
    cp -v ./files/RPM-GPG-KEY-PGDG /etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG
fi

curl -L -o ./files/yq https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64
cp -v ./files/yq ${CONTAINER_PATH}/usr/local/bin/yq
chmod 0755 ${CONTAINER_PATH}/usr/local/bin/yq

dnf_cache
dnf_install_with_docs "bash-completion"
dnf_install "sudo less findutils curl vi nano telnet hostname iputils iproute mtr tmux lsof knot-utils tar unzip zstd gzip rsync jq htop openssh-clients tcpdump postgresql14"
dnf_clean_cache
dnf_clean

rsync_rootfs

buildah run ${CONTAINER_UUID} useradd --comment "ToolBox" --create-home --shell /usr/bin/bash toolbox

buildah config --volume /home/toolbox/.ssh ${CONTAINER_UUID}

commit_container toolbox ${IMAGE_TAG}


CONTAINER_UUID=$(create_container toolbox ${IMAGE_TAG})
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

buildah config --cmd '[ "/usr/bin/bash" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGINT' ${CONTAINER_UUID}
buildah config --volume - ${CONTAINER_UUID}
buildah config --user toolbox ${CONTAINER_UUID}
buildah config --workingdir /home/toolbox ${CONTAINER_UUID}

commit_container base/toolbox ${IMAGE_TAG}
