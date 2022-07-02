#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create openjdk11-jre ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK_VERSION}/keycloak-${KEYCLOAK_VERSION}.tar.gz|tar xzv
popd
mv -v ${TMP_DIR}/keycloak-${KEYCLOAK_VERSION} ${CONTAINER_PATH}/usr/lib/keycloak
chown -R root:root ${CONTAINER_PATH}/usr/lib/keycloak
rm -vrf ${TMP_DIR}

rsync_rootfs
sed -i "s/POSTGRESQL_JDBC_VERSION/${POSTGRESQL_JDBC_VERSION}/" ${CONTAINER_PATH}/usr/lib/keycloak/modules/system/layers/keycloak/org/postgresql/main/module.xml

curl -L https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_JDBC_VERSION}.jar\
 -o ${CONTAINER_PATH}/usr/lib/keycloak/modules/system/layers/keycloak/org/postgresql/main/postgresql-${POSTGRESQL_JDBC_VERSION}.jar

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 keycloak.service

# Standalone mode
buildah config --volume /usr/lib/keycloak/standalone/data ${CONTAINER_UUID}
buildah config --volume /usr/lib/keycloak/standalone/log ${CONTAINER_UUID}
# Domain mode
#buildah config --volume /usr/lib/keycloak/domain/data ${CONTAINER_UUID}
#buildah config --volume /usr/lib/keycloak/domain/log ${CONTAINER_UUID}

container_commit keycloak ${IMAGE_TAG}
