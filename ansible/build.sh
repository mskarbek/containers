. ../meta/common.sh

CONTAINER_UUID=$(create_container base/python36:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/epel.repo ${CONTAINER_PATH}/etc/yum.repos.d/epel.repo
    cp -v ./files/RPM-GPG-KEY-EPEL-8 /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
fi

dnf_cache
dnf_install "--enablerepo=openstack-16-tools-for-rhel-8-x86_64-rpms ansible openssh-clients git-core rsync ara"
dnf_clean_cache
dnf_clean

commit_container base/ansible:latest
