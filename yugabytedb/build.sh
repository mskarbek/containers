#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

container_create systemd ${1}

dnf_cache
dnf_install "findutils python3"
dnf_cache_clean
dnf_clean

pushd ${CONTAINER_PATH}/usr/lib
    curl -L https://downloads.yugabyte.com/releases/${YUGABYTEDB_VERSION}/yugabyte-${YUGABYTEDB_VERSION}-b${YUGABYTEDB_BUILD}-linux-x86_64.tar.gz|tar xzv
popd
ln -s ./yugabyte-${YUGABYTEDB_VERSION} ${CONTAINER_PATH}/usr/lib/yugabyte

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} /usr/sbin/alternatives --set python /usr/bin/python3
buildah run --network none --workingdir=/usr/lib/yugabyte ${CONTAINER_UUID} /usr/bin/bash /usr/lib/yugabyte/bin/post_install.sh
buildah run --network none ${CONTAINER_UUID} systemctl enable\
 yb-master.service\
 yb-tserver.service

buildah config --volume /etc/yugabyte ${CONTAINER_UUID}
buildah config --volume /var/lib/yugabyte ${CONTAINER_UUID}
buildah config --volume /var/log/yugabyte ${CONTAINER_UUID}

container_commit yugabytedb ${IMAGE_TAG}
