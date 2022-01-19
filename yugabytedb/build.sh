. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "findutils python3"
dnf_clean_cache
dnf_clean

if [ -f "./files/yugabyte-${YUGABYTEDB_VERSION}-b${YUGABYTEDB_BUILD}-linux-x86_64.tar.gz" ]; then
    tar xvf ./files/yugabyte-${YUGABYTEDB_VERSION}-b${YUGABYTEDB_BUILD}-linux-x86_64.tar.gz -C ${CONTAINER_PATH}/usr/lib
else
    pushd ${CONTAINER_PATH}/usr/lib
        curl -L https://downloads.yugabyte.com/releases/${YUGABYTEDB_VERSION}/yugabyte-${YUGABYTEDB_VERSION}-b${YUGABYTEDB_BUILD}-linux-x86_64.tar.gz|tar xzv
    popd
fi
ln -s ./yugabyte-${YUGABYTEDB_VERSION} ${CONTAINER_PATH}/usr/lib/yugabyte

rsync_rootfs

buildah run ${CONTAINER_UUID} /usr/sbin/alternatives --set python /usr/bin/python3
buildah run --workingdir=/usr/lib/yugabyte ${CONTAINER_UUID} /usr/bin/bash /usr/lib/yugabyte/bin/post_install.sh
buildah run ${CONTAINER_UUID} systemctl enable\
 yb-master.service\
 yb-tserver.service

buildah config --volume /etc/yugabyte ${CONTAINER_UUID}
buildah config --volume /var/lib/yugabyte ${CONTAINER_UUID}
buildah config --volume /var/log/yugabyte ${CONTAINER_UUID}

commit_container yugabytedb:latest
