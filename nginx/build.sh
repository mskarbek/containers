. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_module "disable php"
dnf_module "enable nginx:1.20"
dnf_install "nginx"
dnf_clean_cache
dnf_clean

rm -vf ${CONTAINER_PATH}/usr/share/nginx/html/index.html
touch ${CONTAINER_PATH}/usr/share/nginx/html/index.html

buildah run -t ${CONTAINER_UUID} systemctl enable\
 nginx.service

buildah config --volume /etc/nginx/conf.d ${CONTAINER_UUID}

commit_container nginx:latest
