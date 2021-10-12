CONTAINER_ID=$(buildah from 10.88.0.2:8082/systemd:latest)
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
 install https://download.konghq.com/gateway-2.x-rhel-8/Packages/k/kong-2.4.1.rhel8.amd64.rpm
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

buildah commit ${CONTAINER_ID} 10.88.0.2:8082/kong:latest
buildah rm -a
