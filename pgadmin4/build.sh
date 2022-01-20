. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_module "disable postgresql"
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/pgdg-redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/pgdg-redhat.repo
    cp -v ./files/pgadmin4.repo ${CONTAINER_PATH}/etc/yum.repos.d/pgadmin4.repo
    cp -v ./files/RPM-GPG-KEY-PGDG /etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG
    cp -v ./files/RPM-GPG-KEY-PGADMIN /etc/pki/rpm-gpg/RPM-GPG-KEY-PGADMIN
    dnf_install "libstdc++ pgadmin4-web"
else
    dnf_install "libstdc++ pgadmin4-web"
fi
dnf_clean_cache
dnf_clean

#buildah run -t ${CONTAINER_UUID} /usr/pgadmin4/bin/setup-web.sh

commit_container pgadmin4:latest
