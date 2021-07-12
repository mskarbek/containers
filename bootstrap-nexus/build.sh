. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} registry.fedoraproject.org/fedora:34
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

NEXUS_VERSION="3.32.0-03"

TMPDIR=$(mktemp -d)

buildah run -t ${CONTAINER_UUID} dnf -y\
 --releasever=34\
 --setopt=install_weak_deps=false\
 --nodocs\
 update

buildah run -t ${CONTAINER_UUID} dnf -y\
 --releasever=34\
 --setopt=install_weak_deps=false\
 --nodocs\
 install systemd procps-ng dbus-broker java-1.8.0-openjdk-headless tomcat-native apr

buildah run -t ${CONTAINER_UUID} dnf -y\
 --releasever=34\
 clean all

pushd ${TMPDIR}
curl -L https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz|tar xzv
popd

mkdir ${CONTAINER_PATH}/usr/lib/sonatype
pushd ${CONTAINER_PATH}/usr/lib/sonatype
mv -v ${TMPDIR}/nexus-${NEXUS_VERSION} ./
mv -v ${TMPDIR}/sonatype-work ./
ln -s nexus-${NEXUS_VERSION} nexus
popd

rm -rf ${TMPDIR}

rsync_rootfs

cp -v files/nexus.vmoptions ${CONTAINER_PATH}/usr/lib/sonatype/nexus/bin/nexus.vmoptions
cp -v files/keystore.p12 ${CONTAINER_PATH}/usr/lib/sonatype/sonatype-work/nexus3/keystores/keystore.p12

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

buildah run -t ${CONTAINER_UUID} systemctl enable\
 dbus-broker.service\
 nexus.service

clean_files

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}

buildah commit ${CONTAINER_UUID} ${REGISTRY}/bootstrap-nexus:$(date +'%Y.%m.%d')-1
buildah rm -a
