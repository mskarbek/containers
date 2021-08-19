. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/bootstrap/micro:$(date +'%Y.%m.%d')-1
else
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/micro:$(date +'%Y.%m.%d')-1
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    REPODIR="/var/tmp/$(cat /proc/sys/kernel/random/uuid)"
    mkdir -vp ${REPODIR}

    cat << EOF > /etc/yum.repos.d/hyperscale.repo
[hyperscale]
name=CentOS 8 Stream - Hyperscale
baseurl=http://mirror.centos.org/centos/8-stream/hyperscale/x86_64/packages-main/
enabled=1
gpgcheck=0

[hyperscale-facebook]
name=CentOS 8 Stream - Hyperscale Facebook
baseurl=http://mirror.centos.org/centos/8-stream/hyperscale/x86_64/packages-facebook/
enabled=1
gpgcheck=0
EOF
    
    reposync -p ${REPODIR} --download-metadata --repo=hyperscale
    reposync -p ${REPODIR} --download-metadata --repo=hyperscale-facebook

    cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
        cat << EOF > ${CONTAINER_PATH}/etc/yum.repos.d/hyperscale.repo
[hyperscale]
name=CentOS 8 Stream - Hyperscale
baseurl=file://${REPODIR}/hyperscale
enabled=1
gpgcheck=0

[hyperscale-facebook]
name=CentOS 8 Stream - Hyperscale Facebook
baseurl=file://${REPODIR}/hyperscale-facebook
enabled=1
gpgcheck=0
EOF

    dnf_install "systemd procps-ng"
    
    rm -vf /etc/yum.repos.d/hyperscale.repo
    rm -rf ${REPODIR}
else
    dnf_install "systemd procps-ng dbus-broker"
fi

dnf_clean

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl mask\
 console-getty.service\
 dev-hugepages.mount\
 dnf-makecache.timer\
 getty.target\
 kdump.service\
 sys-fs-fuse-connections.mount\
 systemd-homed.service\
 systemd-hostnamed.service\
 systemd-logind.service\
 systemd-machine-id-commit.service\
 systemd-random-seed.service\
 systemd-remount-fs.service\
 systemd-resolved.service\
 systemd-udev-trigger.service\
 systemd-udevd.service

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    rm -v\
     ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo\
     ${CONTAINER_PATH}/etc/yum.repos.d/hyperscale.repo
else
    buildah run -t ${CONTAINER_UUID} systemctl enable\
     dbus-broker.service
fi

clean_files

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/base:$(date +'%Y.%m.%d')-1
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/base:$(date +'%Y.%m.%d')-1
fi
buildah rm -a
