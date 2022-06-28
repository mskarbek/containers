#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create openjdk11-jre ${1}

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -LO https://dlcdn.apache.org/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
    curl -Lo guacamole-${GUACAMOLE_VERSION}.war https://apache.org/dyn/closer.lua/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-${GUACAMOLE_VERSION}.war?action=download
    curl -Lo guacamole-auth-jdbc-${GUACAMOLE_VERSION}.tar.gz https://apache.org/dyn/closer.lua/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-auth-jdbc-${GUACAMOLE_VERSION}.tar.gz?action=download
    curl -Lo guacamole-auth-ldap-${GUACAMOLE_VERSION}.tar.gz https://apache.org/dyn/closer.lua/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-auth-ldap-${GUACAMOLE_VERSION}.tar.gz?action=download
    curl -Lo guacamole-auth-totp-${GUACAMOLE_VERSION}.tar.gz https://apache.org/dyn/closer.lua/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-auth-totp-${GUACAMOLE_VERSION}.tar.gz?action=download
    curl -Lo guacamole-auth-sso-${GUACAMOLE_VERSION}.tar.gz https://apache.org/dyn/closer.lua/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-auth-sso-${GUACAMOLE_VERSION}.tar.gz?action=download
popd
mkdir -vp ${CONTAINER_PATH}/usr/lib/guacamole/{extensions,lib}
pushd ${CONTAINER_PATH}/usr/lib/guacamole
    tar -xvf --strip-components=1 ${TMP_DIR}/apache-tomcat-${TOMCAT_VERSION}.tar.gz
    mv -v ${TMP_DIR}/guacamole-${GUACAMOLE_VERSION}.war ./webapp/guacamole.war
    mv -v ${TMP_DIR}/sonatype-work ./
    ln -s ./nexus-${NEXUS_VERSION} nexus
popd 
rm -vrf ${TMP_DIR}

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 guacamole.service

buildah config --volume /etc/guacamole ${CONTAINER_UUID}

container_commit guacamole ${IMAGE_TAG}
