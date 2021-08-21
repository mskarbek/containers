REGISTRY='10.88.0.249:8082'

dnf_install () {
    dnf -y \
    --installroot=${CONTAINER_PATH} \
    --releasever=8.4 \
    --setopt=module_platform_id=platform:el8 \
    --setopt=install_weak_deps=false \
    --nodocs \
    install ${1}
}

dnf_module () {
    dnf -y \
    --installroot=${CONTAINER_PATH} \
    --releasever=8.4 \
    --setopt=module_platform_id=platform:el8 \
    --setopt=install_weak_deps=false \
    --nodocs \
    module ${1}
}

dnf_clean () {
    dnf -y \
    --installroot=${CONTAINER_PATH} \
    --releasever=8.4 \
    clean all
}

rsync_rootfs () {
    rsync -hrvP --exclude '.gitkeep' --ignore-existing rootfs/ ${CONTAINER_PATH}/
}

clean_files () {
    rm -rvf \
    ${CONTAINER_PATH}/var/cache/* \
    ${CONTAINER_PATH}/var/log/dnf* \
    ${CONTAINER_PATH}/var/log/yum* \
    ${CONTAINER_PATH}/var/log/hawkey* \
    ${CONTAINER_PATH}/var/log/rhsm
}

clean_repos () {
    rm -rvf \
    ${CONTAINER_PATH}/etc/yum.repos.d/*
}
