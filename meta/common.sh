TXT_YELLOW="\e[1;93m"
TXT_CLEAR="\e[0m"
#echo -e "${TXT_YELLOW}${TXT_CLEAR}"

container_create () {
    CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
    if [ -z ${2} ]; then
        if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
            echo -e "${TXT_YELLOW}from: ${OCI_REGISTRY_URL}/bootstrap/${1}:latest${TXT_CLEAR}"
            buildah from --quiet --name=${CONTAINER_UUID} ${OCI_REGISTRY_URL}/bootstrap/${1}:latest
        else
            echo -e "${TXT_YELLOW}from: ${OCI_REGISTRY_URL}/${1}:latest${TXT_CLEAR}"
            buildah from --quiet --name=${CONTAINER_UUID} ${OCI_REGISTRY_URL}/${1}:latest
        fi
    else
        if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
            echo -e "${TXT_YELLOW}from: ${OCI_REGISTRY_URL}/bootstrap/${1}:${2}${TXT_CLEAR}"
            buildah from --quiet --name=${CONTAINER_UUID} ${OCI_REGISTRY_URL}/bootstrap/${1}:${2}
        else
            echo -e "${TXT_YELLOW}from: ${OCI_REGISTRY_URL}/${1}:${2}${TXT_CLEAR}"
            buildah from --quiet --name=${CONTAINER_UUID} ${OCI_REGISTRY_URL}/${1}:${2}
        fi
    fi
    CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})
}

container_commit () {
    files_clean
    if [ -z ${2} ]; then
        if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
            echo -e "${TXT_YELLOW}commit: ${OCI_REGISTRY_URL}/bootstrap/${1}:latest${TXT_CLEAR}"
            buildah commit --quiet ${CONTAINER_UUID} ${OCI_REGISTRY_URL}/bootstrap/${1}:latest
        else
            echo -e "${TXT_YELLOW}commit: ${OCI_REGISTRY_URL}/${1}:latest${TXT_CLEAR}"
            buildah commit --quiet ${CONTAINER_UUID} ${OCI_REGISTRY_URL}/${1}:latest
        fi
    else
        if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
            echo -e "${TXT_YELLOW}commit: ${OCI_REGISTRY_URL}/bootstrap/${1}:${2}${TXT_CLEAR}"
            buildah commit --quiet ${CONTAINER_UUID} ${OCI_REGISTRY_URL}/bootstrap/${1}:${2}
            echo -e "${TXT_YELLOW}tag: ${OCI_REGISTRY_URL}/bootstrap/${1}:latest${TXT_CLEAR}"
            buildah tag ${OCI_REGISTRY_URL}/bootstrap/${1}:${2} ${OCI_REGISTRY_URL}/bootstrap/${1}:latest
        else
            echo -e "${TXT_YELLOW} commit: ${OCI_REGISTRY_URL}/${1}:${2}${TXT_CLEAR}"
            buildah commit --quiet ${CONTAINER_UUID} ${OCI_REGISTRY_URL}/${1}:${2}
            echo -e "${TXT_YELLOW} tag: ${OCI_REGISTRY_URL}/${1}:latest${TXT_CLEAR}"
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
    if [ ${IMAGE_BOOTSTRAP} == "true" ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
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
    if [ ${IMAGE_BOOTSTRAP} == "true" ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
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
    if [ ${IMAGE_BOOTSTRAP} == "true" ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
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
    if [ ${IMAGE_BOOTSTRAP} == "true" ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
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
    if [ ${IMAGE_BOOTSTRAP} == "true" ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
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
    if [ ${IMAGE_BOOTSTRAP} == "true" ] && [ -d ${CONTAINER_PATH}/etc/yum.repos.d ]; then
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
    rm -rf ${UPPERDIR} ${WORKDIR}
}

rsync_rootfs () {
    rsync -rv --exclude '.gitkeep' --ignore-existing ${@} rootfs/ ${CONTAINER_PATH}/
}

files_clean () {
    echo -e "${TXT_YELLOW}delete: cache files${TXT_CLEAR}"
    rm -rf\
     ${CONTAINER_PATH}/var/cache/*\
     ${CONTAINER_PATH}/var/log/dnf*\
     ${CONTAINER_PATH}/var/log/yum*\
     ${CONTAINER_PATH}/var/log/hawkey*\
     ${CONTAINER_PATH}/var/log/rhsm
}

repos_clean () {
    echo -e "${TXT_YELLOW}delete: repo files${TXT_CLEAR}"
    rm -rf\
     ${CONTAINER_PATH}/etc/yum.repos.d/*
}

skopeo_login () {
    echo ${OCI_REGISTRY_PASSWORD} | skopeo login --tls-verify=false -u ${OCI_REGISTRY_USER} --password-stdin ${OCI_REGISTRY_URL}
}

skopeo_copy () {
    if [ -z ${2} ]; then
        if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
            echo -e "${TXT_YELLOW}push: ${OCI_REGISTRY_URL}/bootstrap/${1}:latest${TXT_CLEAR}"
            skopeo copy --quiet --format oci containers-storage:${OCI_REGISTRY_URL}/bootstrap/${1}:latest docker://${OCI_REGISTRY_URL}/bootstrap/${1}:latest
        else
            echo -e "${TXT_YELLOW}push: ${OCI_REGISTRY_URL}/${1}:latest${TXT_CLEAR}"
            skopeo copy --quiet --format oci containers-storage:${OCI_REGISTRY_URL}/${1}:latest docker://${OCI_REGISTRY_URL}/${1}:latest
        fi
    else
        if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
            echo -e "${TXT_YELLOW}push: ${OCI_REGISTRY_URL}/bootstrap/${1}:${2}${TXT_CLEAR}"
            skopeo copy --quiet --format oci containers-storage:${OCI_REGISTRY_URL}/bootstrap/${1}:${2} docker://${OCI_REGISTRY_URL}/bootstrap/${1}:${2}
            echo -e "${TXT_YELLOW}push: ${OCI_REGISTRY_URL}/bootstrap/${1}:latest${TXT_CLEAR}"
            skopeo copy --quiet --format oci containers-storage:${OCI_REGISTRY_URL}/bootstrap/${1}:latest docker://${OCI_REGISTRY_URL}/bootstrap/${1}:latest
        else
            echo -e "${TXT_YELLOW}push: ${OCI_REGISTRY_URL}/${1}:${2}${TXT_CLEAR}"
            skopeo copy --quiet --format oci containers-storage:${OCI_REGISTRY_URL}/${1}:${2} docker://${OCI_REGISTRY_URL}/${1}:${2}
            echo -e "${TXT_YELLOW}push: ${OCI_REGISTRY_URL}/${1}:latest${TXT_CLEAR}"
            skopeo copy --quiet --format oci containers-storage:${OCI_REGISTRY_URL}/${1}:latest docker://${OCI_REGISTRY_URL}/${1}:latest
        fi
    fi
}
