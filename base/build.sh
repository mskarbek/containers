. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/bootstrap/micro:latest
else
    buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/micro:latest
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    REPODIR="$(pwd)/files"

    cp -v /etc/yum.repos.d/redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/redhat.repo
        cat << EOF > ${CONTAINER_PATH}/etc/yum.repos.d/hyperscale.repo
[hyperscale-main]
name=CentOS 8 Stream - Hyperscale Main
baseurl=file://${REPODIR}/hyperscale-main
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
else
    dnf_install "systemd procps-ng dbus-broker"
fi

dnf_clean
dnf_clean_cache

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
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap/base:latest
else
    buildah commit ${CONTAINER_UUID} ${REGISTRY}/base:latest
fi
buildah rm -a
