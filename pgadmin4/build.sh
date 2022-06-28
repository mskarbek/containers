#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create python3 ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/pgdg-redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/pgdg-redhat.repo
fi
rpm --import --root=${CONTAINER_PATH} ./files/RPM-GPG-KEY-PGDG
dnf_install "libstdc++ postgresql12 postgresql13 postgresql14 python3-psycopg2"
dnf_install "python3-six python3-pycparser python3-dateutil python3-idna python3-jmespath python3-greenlet python3-click python3-pytz"
dnf_install "python3-cffi python3-sqlalchemy python3-pynacl python3-mako python3-babel python3-bcrypt python3-brotli python3-simplejson"
dnf_install "python3-certifi python3-chardet python3-ldap3 python3-psutil python3-pyasn1 python3-urllib3 python3-requests python3-sqlparse"
dnf_cache_clean
dnf_clean

buildah run ${CONTAINER_UUID} pip3 install pgadmin4==${PGADMIN4_VERSION} gunicorn

#cat << EOF > ${CONTAINER_PATH}/usr/pgadmin4/web/config_distro.py
#DEFAULT_BINARY_PATHS = {
#        'pg': '/usr/pgsql-14/bin',
#        'pg-14': '/usr/pgsql-14/bin',
#        'pg-13': '/usr/pgsql-13/bin',
#        'pg-12': '/usr/pgsql-12/bin'
#}
#EOF
#
#rsync_rootfs
#
#buildah run --network none ${CONTAINER_UUID} systemctl enable\
# pgadmin4.service

buildah config --volume /etc/pgadmin ${CONTAINER_UUID}
buildah config --volume /var/lib/pgadmin ${CONTAINER_UUID}
buildah config --volume /var/log/pgadmin ${CONTAINER_UUID}

#container_commit pgadmin4 ${IMAGE_TAG}
