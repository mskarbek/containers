REGISTRY='10.88.0.1:8082'

CONTAINER_ID=$(buildah from ${REGISTRY}/systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_ID})

ln -s /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/host.repo

dnf -y\
 --disablerepo=*\
 --enablerepo=rhel-8-for-x86_64-baseos-rpms\
 --enablerepo=rhel-8-for-x86_64-appstream-rpms\
 --installroot=${CONTAINER_PATH}\
 --releasever=8.4\
 --setopt=module_platform_id=platform:el8\
 --setopt=install_weak_deps=false\
 --nodocs\
 install httpd subversion mod_dav_svn
dnf -y\
 --installroot=${CONTAINER_PATH}\
 --releasever=8.4\
 clean all

rm -rvf\
 ${CONTAINER_PATH}/var/cache/*\
 ${CONTAINER_PATH}/var/log/dnf*\
 ${CONTAINER_PATH}/var/log/yum*\
 ${CONTAINER_PATH}/var/log/hawkey*\
 ${CONTAINER_PATH}/var/log/rhsm\
 ${CONTAINER_PATH}/etc/yum.repos.d/host.repo

buildah commit ${CONTAINER_ID} ${REGISTRY}/subversion:latest
buildah rm -a
