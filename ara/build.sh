. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container python36:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/epel.repo ${CONTAINER_PATH}/etc/yum.repos.d/epel.repo
    cp -v ./files/RPM-GPG-KEY-EPEL-8 /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
fi

dnf_cache
dnf_install "python3-psycopg2 python3-gunicorn"
dnf_clean_cache
dnf_clean

TMP_DIR=$(buildah run ${CONTAINER_UUID} mktemp -d)
if [ -f "./files/ara-${ARA_VERSION}.tar.gz" ]; then
    tar xvf ./files/ara-${ARA_VERSION}.tar.gz -C ${CONTAINER_PATH}/${TMP_DIR}
else
    pushd ${CONTAINER_PATH}/${TMP_DIR}
        curl -L https://files.pythonhosted.org/packages/source/a/ara/ara-${ARA_VERSION}.tar.gz|tar xzv
    popd
fi
buildah run -t ${CONTAINER_UUID} pip3 install ${TMP_DIR}/ara-${ARA_VERSION}[server]
rm -rf ${CONTAINER_PATH}/${TMP_DIR}

rm -rvf ${CONTAINER_PATH}/root/.cache
rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 ara-migrate.service\
 ara-server.service

buildah config --volume /var/lib/ara ${CONTAINER_UUID}
buildah config --volume /var/log/ara ${CONTAINER_UUID}

commit_container ara:latest
