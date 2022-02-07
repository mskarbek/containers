. ../meta/common.sh

TOOLS="less findutils curl vi nano telnet hostname iputils iproute mtr tmux lsof knot-utils tar unzip zstd gzip rsync jq htop openssh-clients tcpdump postgresql14"

CONTAINER_UUID=$(create_container base:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/pgdg-redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/pgdg-redhat.repo
    cp -v ./files/RPM-GPG-KEY-PGDG /etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG
fi

dnf_cache
dnf_module "disable postgresql"
dnf_install ${TOOLS}
dnf_clean_cache
dnf_clean

commit_container base/toolbox:latest


CONTAINER_UUID=$(create_container openssh:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/pgdg-redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/pgdg-redhat.repo
    cp -v ./files/RPM-GPG-KEY-PGDG /etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG
fi

dnf_cache
dnf_module "disable postgresql"
dnf_install ${TOOLS}
dnf_clean_cache
dnf_clean

commit_container toolbox:latest
