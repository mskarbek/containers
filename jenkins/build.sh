. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --name=${CONTAINER_UUID} ${REGISTRY}/openjdk11-jre:$(date +'%Y.%m.%d')-1
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

copy_repo

rsync_rootfs
cp rootfs/etc/pki/rpm-gpg/RPM-GPG-KEY-jenkins /etc/pki/rpm-gpg/RPM-GPG-KEY-jenkins

dnf_install "fontconfig jenkins git-core"

dnf_clean

curl -L -o ${CONTAINER_PATH}/usr/lib/jenkins/jenkins-plugin-manager.jar https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.10.0/jenkins-plugin-manager-2.10.0.jar

clean_files

buildah run -t ${CONTAINER_UUID} systemctl enable\
 jenkins.service\
 jenkins-plugin-manager.service

buildah config --volume /var/lib/jenkins ${CONTAINER_UUID}

buildah commit ${CONTAINER_UUID} ${REGISTRY}/jenkins:$(date +'%Y.%m.%d')-1
buildah rm -a
