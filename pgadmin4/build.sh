. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/{pgdg-redhat,pgadmin4}.repo ${CONTAINER_PATH}/etc/yum.repos.d/
    cp -v ./files/RPM-GPG-KEY-{PGDG,PGADMIN} /etc/pki/rpm-gpg/
fi

dnf_cache
dnf_module "disable postgresql"
dnf_install "libstdc++ pgadmin4-server postgresql12 postgresql13 postgresql14"
dnf_clean_cache
dnf_clean

buildah run -t ${CONTAINER_UUID} bash -c "source /usr/pgadmin4/venv/bin/activate; pip3 install gunicorn"

cat << EOF > ${CONTAINER_PATH}/usr/pgadmin4/web/config_distro.py
DEFAULT_BINARY_PATHS = {
        'pg': '/usr/pgsql-14/bin',
        'pg-14': '/usr/pgsql-14/bin',
        'pg-13': '/usr/pgsql-13/bin',
        'pg-12': '/usr/pgsql-12/bin'
}
EOF

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 pgadmin4.service

buildah config --volume /etc/pgadmin ${CONTAINER_UUID}
buildah config --volume /var/lib/pgadmin ${CONTAINER_UUID}
buildah config --volume /var/log/pgadmin ${CONTAINER_UUID}

commit_container pgadmin4:latest
