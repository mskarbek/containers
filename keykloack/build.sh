. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container openjdk11-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

TMP_DIR=$(mktemp -d)
if [ -f "./files/keycloak-${KEYCLOAK_VERSION}.tar.gz" ]; then
    tar xvf ./files/keycloak-${KEYCLOAK_VERSION}.tar.gz -C ${TMP_DIR}
else
    pushd ${TMP_DIR}
        curl -L https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK_VERSION}/keycloak-${KEYCLOAK_VERSION}.tar.gz|tar xzv
    popd
fi
mv -v ${TMP_DIR}/keycloak-${KEYCLOAK_VERSION} ${CONTAINER_PATH}/usr/lib/keycloak
rm -rf ${TMP_DIR}

rsync_rootfs
sed -i "s/POSTGRESQL_JDBC_VERSION/${POSTGRESQL_JDBC_VERSION}/" ${CONTAINER_PATH}/usr/lib/keycloak/modules/system/layers/keycloak/org/postgresql/main/module.xml

if [ -f "./files/postgresql-${POSTGRESQL_JDBC_VERSION}.jar" ]; then
    cp -v ./files/postgresql-${POSTGRESQL_JDBC_VERSION}.jar ${CONTAINER_PATH}/usr/lib/keycloak/modules/system/layers/keycloak/org/postgresql/main/
else
    curl -L https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_JDBC_VERSION}.jar\
     -o ${CONTAINER_PATH}/usr/lib/keycloak/modules/system/layers/keycloak/org/postgresql/main//postgresql-${POSTGRESQL_JDBC_VERSION}.jar
fi

buildah run -t ${CONTAINER_UUID} systemctl enable\
 keycloak.service

buildah config --volume /etc/kuma ${CONTAINER_UUID}
buildah config --volume /var/log/kuma ${CONTAINER_UUID}

commit_container keycloak:latest
