. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/kong-gateway.repo ${CONTAINER_PATH}/etc/yum.repos.d/kong-gateway.repo
    cp -v ./files/RPM-GPG-KEY-Kong-Gateway /etc/pki/rpm-gpg/RPM-GPG-KEY-Kong-Gateway
    dnf_install "kong hostname"
else
    dnf_install "kong hostname"
fi
dnf_clean_cache
dnf_clean

cp -v ${CONTAINER_PATH}/etc/kong/kong.conf.default ${CONTAINER_PATH}/etc/kong/kong.conf

sed -i 's/#anonymous_reports = on/anonymous_reports = off/' ${CONTAINER_PATH}/etc/kong/kong.conf
sed -i 's/#database = postgres/database = off      /' ${CONTAINER_PATH}/etc/kong/kong.conf
sed -i 's/#declarative_config =          /declarative_config = \/etc\/kong\/kong\.yaml/' ${CONTAINER_PATH}/etc/kong/kong.conf

buildah run -t ${CONTAINER_UUID} kong config init /etc/kong/kong.yaml
buildah run -t ${CONTAINER_UUID} systemctl enable\
 kong.service

commit_container kong:latest
