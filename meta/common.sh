container_create () {
    CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
    if [ -z ${2} ]; then
        if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
            buildah from --name=${CONTAINER_UUID} ${OCI_REGISTRY_URL}/bootstrap/${1}:latest
        else
            buildah from --name=${CONTAINER_UUID} ${OCI_REGISTRY_URL}/${1}:latest
        fi
    else
        if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
            buildah from --name=${CONTAINER_UUID} ${OCI_REGISTRY_URL}/bootstrap/${1}:${2}
        else
            buildah from --name=${CONTAINER_UUID} ${OCI_REGISTRY_URL}/${1}:${2}
        fi
    fi
    CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})
}

container_commit () {
    files_clean
    if [ -z ${2} ]; then
        if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
            buildah commit ${CONTAINER_UUID} ${OCI_REGISTRY_URL}/bootstrap/${1}:latest
        else
            buildah commit ${CONTAINER_UUID} ${OCI_REGISTRY_URL}/${1}:latest
        fi
    else
        if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
            buildah commit ${CONTAINER_UUID} ${OCI_REGISTRY_URL}/bootstrap/${1}:${2}
            buildah tag ${OCI_REGISTRY_URL}/bootstrap/${1}:${2} ${OCI_REGISTRY_URL}/bootstrap/${1}:latest
        else
            buildah commit ${CONTAINER_UUID} ${OCI_REGISTRY_URL}/${1}:${2}
            buildah tag ${OCI_REGISTRY_URL}/${1}:${2} ${OCI_REGISTRY_URL}/${1}:latest
        fi
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
        if [ ${OS_TYPE} = "el9" ]; then
            cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
        elif [ ${OS_TYPE} = "c9s" ]; then
            cp -v /etc/yum.repos.d/CentOS-Stream-{BaseOS,AppStream,PowerTools,HighAvailability}.repo ${CONTAINER_PATH}/etc/yum.repos.d/
        else
            printf "ERROR: Missing or incorrect OS_TYPE variable." >&2
            exit 1
        fi
    fi
    dnf -y\
     --installroot=${CONTAINER_PATH}\
     --releasever=9\
     --setopt=module_platform_id=platform:el9\
     --setopt=install_weak_deps=false\
     --nodocs\
     install ${@}
    if [ ! -z ${IMAGE_BOOTSTRAP} ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
        if [ ${OS_TYPE} = "el9" ]; then
            rm -vf ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
        elif [ ${OS_TYPE} = "c9s" ]; then
            rm -vf ${CONTAINER_PATH}/etc/yum.repos.d/CentOS-Stream-{BaseOS,AppStream,PowerTools,HighAvailability}.repo
        else
            printf "ERROR: Missing or incorrect OS_TYPE variable." >&2
            exit 1
        fi
    fi
}

dnf_install_with_docs () {
    if [ ! -z ${IMAGE_BOOTSTRAP} ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
        if [ ${OS_TYPE} = "el9" ]; then
            cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
        elif [ ${OS_TYPE} = "c9s" ]; then
            cp -v /etc/yum.repos.d/CentOS-Stream-{BaseOS,AppStream,PowerTools,HighAvailability}.repo ${CONTAINER_PATH}/etc/yum.repos.d/
        else
            printf "ERROR: Missing or incorrect OS_TYPE variable." >&2
            exit 1
        fi
    fi
    dnf -y\
     --installroot=${CONTAINER_PATH}\
     --releasever=9\
     --setopt=module_platform_id=platform:el9\
     --setopt=install_weak_deps=false\
     install ${@}
    if [ ! -z ${IMAGE_BOOTSTRAP} ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
        if [ ${OS_TYPE} = "el9" ]; then
            rm -vf ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
        elif [ ${OS_TYPE} = "c9s" ]; then
            rm -vf ${CONTAINER_PATH}/etc/yum.repos.d/CentOS-Stream-{BaseOS,AppStream,PowerTools,HighAvailability}.repo
        else
            printf "ERROR: Missing or incorrect OS_TYPE variable." >&2
            exit 1
        fi
    fi
}

dnf_module () {
    if [ ! -z ${IMAGE_BOOTSTRAP} ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
        if [ ${OS_TYPE} = "el9" ]; then
            cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
        elif [ ${OS_TYPE} = "c9s" ]; then
            cp -v /etc/yum.repos.d/CentOS-Stream-{BaseOS,AppStream,PowerTools,HighAvailability}.repo ${CONTAINER_PATH}/etc/yum.repos.d/
        else
            printf "ERROR: Missing or incorrect OS_TYPE variable." >&2
            exit 1
        fi
    fi
    dnf -y\
     --installroot=${CONTAINER_PATH}\
     --releasever=9\
     --setopt=module_platform_id=platform:el9\
     --setopt=install_weak_deps=false\
     --nodocs\
     module ${1}
    if [ ! -z ${IMAGE_BOOTSTRAP} ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
        if [ ${OS_TYPE} = "el9" ]; then
            rm -vf ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
        elif [ ${OS_TYPE} = "c9s" ]; then
            rm -vf ${CONTAINER_PATH}/etc/yum.repos.d/CentOS-Stream-{BaseOS,AppStream,PowerTools,HighAvailability}.repo
        else
            printf "ERROR: Missing or incorrect OS_TYPE variable." >&2
            exit 1
        fi
    fi
}

dnf_clean () {
    dnf -y\
     --installroot=${CONTAINER_PATH}\
     --releasever=9\
     clean all
}

dnf_cache_clean () {
    umount ${CONTAINER_PATH}/var/cache/dnf
    rm -vrf ${UPPERDIR} ${WORKDIR}
}

rsync_rootfs () {
    rsync -hrvP --exclude '.gitkeep' --ignore-existing ${@} rootfs/ ${CONTAINER_PATH}/
}

files_clean () {
    rm -vrf\
     ${CONTAINER_PATH}/var/cache/*\
     ${CONTAINER_PATH}/var/log/dnf*\
     ${CONTAINER_PATH}/var/log/yum*\
     ${CONTAINER_PATH}/var/log/hawkey*\
     ${CONTAINER_PATH}/var/log/rhsm
}

repos_clean () {
    rm -vrf\
     ${CONTAINER_PATH}/etc/yum.repos.d/*
}

skopeo_login () {
    echo ${OCI_REGISTRY_PASSWORD} | skopeo login --tls-verify=false -u ${OCI_REGISTRY_USER} --password-stdin ${OCI_REGISTRY_URL}
}

skopeo_copy () {
    if [ -z ${2} ]; then
        if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
            skopeo copy --format oci containers-storage:${OCI_REGISTRY_URL}/bootstrap/${1}:latest docker://${OCI_REGISTRY_URL}/bootstrap/${1}:latest
        else
            skopeo copy --format oci containers-storage:${OCI_REGISTRY_URL}/${1}:latest docker://${OCI_REGISTRY_URL}/${1}:latest
        fi
    else
        if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
            skopeo copy --format oci containers-storage:${OCI_REGISTRY_URL}/bootstrap/${1}:${2} docker://${OCI_REGISTRY_URL}/bootstrap/${1}:${2}
            skopeo copy --format oci containers-storage:${OCI_REGISTRY_URL}/bootstrap/${1}:latest docker://${OCI_REGISTRY_URL}/bootstrap/${1}:latest
        else
            skopeo copy --format oci containers-storage:${OCI_REGISTRY_URL}/${1}:${2} docker://${OCI_REGISTRY_URL}/${1}:${2}
            skopeo copy --format oci containers-storage:${OCI_REGISTRY_URL}/${1}:latest docker://${OCI_REGISTRY_URL}/${1}:latest
        fi
    fi
}
