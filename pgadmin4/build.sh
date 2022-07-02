#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create python3 ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/pgdg-redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/pgdg-redhat.repo
fi
# python3-psycopg2
dnf_install "libstdc++\
 postgresql12\
 postgresql13\
 postgresql14\
 python3-babel\
 python3-bcrypt\
 python3-brotli\
 python3-certifi\
 python3-cffi\
 python3-chardet\
 python3-click\
 python3-dateutil\
 python3-greenlet\
 python3-idna\
 python3-jmespath\
 python3-ldap3\
 python3-mako\
 python3-psutil\
 python3-pyasn1\
 python3-pycparser\
 python3-pynacl\
 python3-pytz\
 python3-requests\
 python3-simplejson\
 python3-six\
 python3-sqlalchemy\
 python3-sqlparse\
 python3-urllib3"
dnf_cache_clean
dnf_clean

buildah run --network host ${CONTAINER_UUID} pip3 install pgadmin4==${PGADMIN4_VERSION} gunicorn

cat << EOF > ${CONTAINER_PATH}/usr/local/lib/python3.9/site-packages/pgadmin4/config_distro.py
DEFAULT_BINARY_PATHS = {
        'pg': '/usr/pgsql-14/bin',
        'pg-14': '/usr/pgsql-14/bin',
        'pg-13': '/usr/pgsql-13/bin',
        'pg-12': '/usr/pgsql-12/bin'
}
EOF

rm -vrf ${CONTAINER_PATH}/root/.cache
rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 pgadmin4.service

buildah config --volume /etc/pgadmin ${CONTAINER_UUID}
buildah config --volume /var/lib/pgadmin ${CONTAINER_UUID}
buildah config --volume /var/log/pgadmin ${CONTAINER_UUID}

container_commit pgadmin4 ${IMAGE_TAG}
