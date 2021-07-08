REGISTRY='10.88.0.252:8082'

copy_repo () {
    cp /etc/yum.repos.d/proxy.repo ${CONTAINER_PATH}/etc/yum.repos.d/proxy.repo
}

dnf_install () {
    dnf -y \
    --disablerepo=* \
    --enablerepo=proxy-* \
    --enablerepo=hosted-* \
    --installroot=${CONTAINER_PATH} \
    --releasever=8.4 \
    --setopt=module_platform_id=platform:el8 \
    --setopt=install_weak_deps=false \
    --nodocs \
    install ${1}
}

dnf_clean () {
    dnf -y \
    --installroot=${CONTAINER_PATH} \
    --releasever=8.4 \
    clean all
}

rsync_rootfs () {
    rsync -hrvP --ignore-existing rootfs/ ${CONTAINER_PATH}/
}

clean_files () {
    rm -rvf \
    ${CONTAINER_PATH}/var/cache/* \
    ${CONTAINER_PATH}/var/log/dnf* \
    ${CONTAINER_PATH}/var/log/yum* \
    ${CONTAINER_PATH}/var/log/hawkey* \
    ${CONTAINER_PATH}/var/log/rhsm \
    ${CONTAINER_PATH}/etc/yum.repos.d/*
}
