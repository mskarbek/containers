#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
dnf_install "findutils"
dnf_install "https://dl.grafana.com/oss/release/grafana-$(jq -r .[0].version ./files/versions.json)-1.x86_64.rpm"
dnf_cache_clean
dnf_clean

ONCALL_VERSION=$(jq -r .[1].version ./files/versions.json)
KUMA_VERSION=$(jq -r .[2].version ./files/versions.json)
PWD_DIR=$(pwd)
TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
        curl -L -O $(jq -r .[1].remote_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${ONCALL_VERSION};g")
        curl -L -O $(jq -r .[2].remote_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${KUMA_VERSION};g")
    else
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -O $(jq -r .[1].local_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${ONCALL_VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
        curl -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" -L -O $(jq -r .[2].local_url ${PWD_DIR}/files/versions.json | sed "s;VERSION;${KUMA_VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
    fi
    unzip $(jq -r .[1].file_name ${PWD_DIR}/files/versions.json | sed "s;VERSION;${ONCALL_VERSION};g")
    unzip $(jq -r .[2].file_name ${PWD_DIR}/files/versions.json | sed "s;VERSION;${KUMA_VERSION};g")
popd
mkdir -vp ${CONTAINER_PATH}/usr/share/grafana/plugins
mv -v ${TMP_DIR}/grafana-oncall-app ${CONTAINER_PATH}/usr/share/grafana/plugins/
mv -v ${TMP_DIR}/kumahq-kuma-datasource ${CONTAINER_PATH}/usr/share/grafana/plugins/
rm -vrf ${TMP_DIR}

rm -vrf ${CONTAINER_PATH}/usr/share/grafana/plugins/kumahq-kuma-datasource/gpx_*darwin*
rm -vrf ${CONTAINER_PATH}/usr/share/grafana/plugins/kumahq-kuma-datasource/gpx_*windows*
rm -vrf ${CONTAINER_PATH}/usr/share/grafana/plugins/kumahq-kuma-datasource/gpx_*arm*

sed -i 's/.*allow_loading_unsigned_plugins.*/allow_loading_unsigned_plugins = "kumahq-kuma-datasource"/g' ${CONTAINER_PATH}/etc/grafana/grafana.ini
mv -v ${CONTAINER_PATH}/etc/grafana ${CONTAINER_PATH}/usr/share/grafana/etc
rm -vrf ${CONTAINER_PATH}/etc/init.d/grafana-server

rsync_rootfs

buildah run --network host ${CONTAINER_UUID} grafana-cli plugins install parca-datasource
buildah run --network host ${CONTAINER_UUID} grafana-cli plugins install parca-panel

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 grafana-server.service

buildah config --volume /etc/grafana ${CONTAINER_UUID}
buildah config --volume /var/lib/grafana ${CONTAINER_UUID}
buildah config --volume /var/log/grafana ${CONTAINER_UUID}

container_commit grafana ${IMAGE_TAG}
