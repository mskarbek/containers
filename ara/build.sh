. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container python3:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "python3-psycopg2 python3-attrs python3-certifi python3-charset-normalizer python3-idna python3-pbr python3-prettytable python3-requests python3-urllib3 python3-wcwidth python3-pygments python3-pyparsing python3-pytz python3-pyyaml python3-ruamel-yaml python3-ruamel-yaml-clib python3-sqlparse"
dnf_clean_cache
dnf_clean

buildah run -t ${CONTAINER_UUID} pip3 install ara[server]==${ARA_VERSION} gunicorn

rm -rvf ${CONTAINER_PATH}/root/.cache
rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 ara-server.service

buildah config --volume /var/lib/ara ${CONTAINER_UUID}
buildah config --volume /var/log/ara ${CONTAINER_UUID}

commit_container ara:latest
