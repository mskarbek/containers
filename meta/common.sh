create_container () {
    CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
    if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
        buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY_URL}/bootstrap/${1}
    else
        buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY_URL}/${1}
    fi    
}

commit_container () {
    clean_files
    if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
        buildah commit ${CONTAINER_UUID} ${REGISTRY_URL}/bootstrap/${1}
    else
        buildah commit ${CONTAINER_UUID} ${REGISTRY_URL}/${1}
    fi
    buildah rm -a
}

dnf_cache () {
    UPPERDIR=$(mktemp -d)
    WORKDIR=$(mktemp -d)
    mkdir -vp ${CONTAINER_PATH}/var/cache/dnf
    mount -t overlay overlay -o lowerdir=/var/cache/dnf,upperdir=${UPPERDIR},workdir=${WORKDIR} ${CONTAINER_PATH}/var/cache/dnf
}

dnf_install () {
    if [ ! -z ${IMAGE_BOOTSTRAP} ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
        if [ ${BASE_OS} = "el8" ]; then
            cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
        elif [ ${BASE_OS} = "c8s" ]; then
            cp -v /etc/yum.repos.d/CentOS*.repo ${CONTAINER_PATH}/etc/yum.repos.d/
        else
            printf "ERROR: Missing or incorrect BASE_OS variable." >&2
            exit 1
        fi
    fi
    dnf -y\
     --installroot=${CONTAINER_PATH}\
     --releasever=8\
     --setopt=module_platform_id=platform:el8\
     --setopt=install_weak_deps=false\
     --nodocs\
     install ${@}
    if [ ! -z ${IMAGE_BOOTSTRAP} ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
        if [ ${BASE_OS} = "el8" ]; then
            rm -vf ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
        elif [ ${BASE_OS} = "c8s" ]; then
            rm -vf ${CONTAINER_PATH}/etc/yum.repos.d/CentOS*.repo
        else
            printf "ERROR: Missing or incorrect BASE_OS variable." >&2
            exit 1
        fi
    fi
}

dnf_install_with_docs () {
    if [ ! -z ${IMAGE_BOOTSTRAP} ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
        if [ ${BASE_OS} = "el8" ]; then
            cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
        elif [ ${BASE_OS} = "c8s" ]; then
            cp -v /etc/yum.repos.d/CentOS*.repo ${CONTAINER_PATH}/etc/yum.repos.d/
        else
            printf "ERROR: Missing or incorrect BASE_OS variable." >&2
            exit 1
        fi
    fi
    dnf -y\
     --installroot=${CONTAINER_PATH}\
     --releasever=8\
     --setopt=module_platform_id=platform:el8\
     --setopt=install_weak_deps=false\
     install ${@}
    if [ ! -z ${IMAGE_BOOTSTRAP} ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
        if [ ${BASE_OS} = "el8" ]; then
            rm -vf ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
        elif [ ${BASE_OS} = "c8s" ]; then
            rm -vf ${CONTAINER_PATH}/etc/yum.repos.d/CentOS*.repo
        else
            printf "ERROR: Missing or incorrect BASE_OS variable." >&2
            exit 1
        fi
    fi
}

dnf_module () {
    if [ ! -z ${IMAGE_BOOTSTRAP} ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
        if [ ${BASE_OS} = "el8" ]; then
            cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
        elif [ ${BASE_OS} = "c8s" ]; then
            cp -v /etc/yum.repos.d/CentOS*.repo ${CONTAINER_PATH}/etc/yum.repos.d/
        else
            printf "ERROR: Missing or incorrect BASE_OS variable." >&2
            exit 1
        fi
    fi
    dnf -y\
     --installroot=${CONTAINER_PATH}\
     --releasever=8\
     --setopt=module_platform_id=platform:el8\
     --setopt=install_weak_deps=false\
     --nodocs\
     module ${1}
    if [ ! -z ${IMAGE_BOOTSTRAP} ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
        if [ ${BASE_OS} = "el8" ]; then
            rm -vf ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
        elif [ ${BASE_OS} = "c8s" ]; then
            rm -vf ${CONTAINER_PATH}/etc/yum.repos.d/CentOS*.repo
        else
            printf "ERROR: Missing or incorrect BASE_OS variable." >&2
            exit 1
        fi
    fi
}

dnf_clean () {
    dnf -y\
     --installroot=${CONTAINER_PATH}\
     --releasever=8\
     clean all
}

dnf_clean_cache () {
    umount ${CONTAINER_PATH}/var/cache/dnf
    rm -rvf ${UPPERDIR} ${WORKDIR}
}

rsync_rootfs () {
    rsync -hrvP --exclude '.gitkeep' --ignore-existing rootfs/ ${CONTAINER_PATH}/
}

clean_files () {
    rm -rvf\
     ${CONTAINER_PATH}/var/cache/*\
     ${CONTAINER_PATH}/var/log/dnf*\
     ${CONTAINER_PATH}/var/log/yum*\
     ${CONTAINER_PATH}/var/log/hawkey*\
     ${CONTAINER_PATH}/var/log/rhsm
}

clean_repos () {
    rm -rvf\
     ${CONTAINER_PATH}/etc/yum.repos.d/*
}
