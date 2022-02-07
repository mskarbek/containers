. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container openssh:latest)
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
dnf_install "--enablerepo=${ENABLE_REPO} ansible openssh-clients git-core rsync ara"
dnf_clean_cache
dnf_clean

if [ -f ./files/mcli ]; then
    cp -v ./files/mcli ${CONTAINER_PATH}/usr/local/bin/
else
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/mcli https://dl.min.io/client/mc/release/linux-amd64/archive/mc.${MCLI_VERSION}
fi
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/mcli

rsync_rootfs
buildah run --workingdir /var/lib/rundeck ${CONTAINER_UUID} ansible-galaxy collection install -r .ansible/requirements.yaml -p .ansible/collections

commit_container rundeck-runner:latest
