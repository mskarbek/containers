. ../meta/functions.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cat << EOF > ${CONTAINER_PATH}/etc/yum.repos.d/beta.repo
[rhel-8-beta-for-x86_64-baseos-rpms]
name=Red Hat Enterprise Linux 8 Beta for x86_64 - BaseOS (RPMs)
baseurl=file:///mnt/BaseOS/
enabled=1
gpgcheck=0

[rhel-8-beta-for-x86_64-appstream-rpms]
name=Red Hat Enterprise Linux 8 Beta for x86_64 - AppStream (RPMs)
baseurl=file:///mnt/AppStream/
enabled=1
gpgcheck=0
EOF
    dnf_module "disable php:7.2 nginx:1.14"
    dnf_module "enable nginx:1.20"
    dnf_install "nginx"
    rm -f ${CONTAINER_PATH}/etc/yum.repos.d/beta.repo
else
    dnf_module "disable php:7.2 nginx:1.14"
    dnf_module "enable nginx:1.20"
    dnf_install "nginx"
fi

dnf_clean
dnf_clean_cache

buildah run -t ${CONTAINER_UUID} systemctl enable\
 nginx.service

clean_files

commit_container nginx1.20:latest
