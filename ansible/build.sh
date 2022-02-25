. ../meta/common.sh

CONTAINER_UUID=$(create_container base/python36:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ${BASE_OS} = "el8" ]; then
    ENABLE_REPO="openstack-16-tools-for-rhel-8-x86_64-rpms"
elif [ ${BASE_OS} = "c8s" ]; then
    cp -v ./files/centos-{sig-ansible,openstack-xena,ceph-pacific}.repo ${CONTAINER_PATH}/etc/yum.repos.d/
    cp -v ./RPM-GPG-KEY-CentOS-SIG-{Cloud,Storage,ConfigManagement} /etc/pki/rpm-gpg/
    ENABLE_REPO="centos-openstack-xena --enablerepo=centos-ceph-pacific"
else
    printf "ERROR: Missing or incorrect BASE_OS variable." >&2
    exit 1
fi

dnf_cache
dnf_install "--enablerepo=${ENABLE_REPO} ansible openssh-clients git-core rsync ara https://download.copr.fedorainfracloud.org/results/mskarbek/epel-ext/epel-8-x86_64/03258221-python-consul/python3-consul-1.1.0-1.el8.noarch.rpm"
dnf_clean_cache
dnf_clean

commit_container base/ansible:latest
