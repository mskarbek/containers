. ../meta/common.sh

TOOLS="curl vi nano telnet hostname iputils iproute mtr tmux lsof bind-utils tar rsync jq htop openssh-clients"

CONTAINER_UUID=$(create_container base:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/{epel.repo,centos-hyperscale.repo} ${CONTAINER_PATH}/etc/yum.repos.d/
    cp -v ./files/{RPM-GPG-KEY-EPEL-8,RPM-GPG-KEY-CentOS-SIG-HyperScale} /etc/pki/rpm-gpg/
fi

dnf_cache
dnf_install ${TOOLS}
dnf_clean_cache
dnf_clean

commit_container base/toolbox:latest


CONTAINER_UUID=$(create_container openssh:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/{epel.repo,centos-hyperscale.repo} ${CONTAINER_PATH}/etc/yum.repos.d/
    cp -v ./files/{RPM-GPG-KEY-EPEL-8,RPM-GPG-KEY-CentOS-SIG-HyperScale} /etc/pki/rpm-gpg/
fi

dnf_cache
dnf_install ${TOOLS}
dnf_clean_cache
dnf_clean

commit_container toolbox:latest
