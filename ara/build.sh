#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create python3 ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/pgdg-redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/pgdg-redhat.repo
fi
cp -v ./files/RPM-GPG-KEY-PGDG ${CONTAINER_PATH}/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG
rpm --import --root=${CONTAINER_PATH} ./files/RPM-GPG-KEY-PGDG
dnf_install "python3-psycopg2 python3-attrs python3-certifi python3-charset-normalizer python3-idna python3-pbr python3-prettytable python3-requests python3-urllib3 python3-wcwidth python3-pygments python3-pyparsing python3-pytz python3-pyyaml python3-ruamel-yaml python3-ruamel-yaml-clib python3-sqlparse"
dnf_cache_clean
dnf_clean

buildah run ${CONTAINER_UUID} pip3 install ara[server]==${ARA_VERSION} gunicorn

rm -vrf ${CONTAINER_PATH}/root/.cache
rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 ara-server.service

buildah config --volume /var/lib/ara ${CONTAINER_UUID}
buildah config --volume /var/log/ara ${CONTAINER_UUID}

container_commit ara ${IMAGE_TAG}
