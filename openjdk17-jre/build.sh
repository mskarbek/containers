. ../meta/functions.sh

CONTAINER_UUID=$(create_container base:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

if [[ ! -z ${IMAGE_BOOTSTRAP} ]]; then
    cat << EOF > ${CONTAINER_PATH}/etc/yum.repos.d/beta.repo
[rhel-8-beta-for-x86_64-baseos-rpms]
name=Red Hat Enterprise Linux 8 Beta for x86_64 - BaseOS (RPMs)
baseurl=file:///mnt/BaseOS/
enabled=1
gpgcheck=0

[rhel-8-beta-for-x86_64-appstream-rpms]
name=Red Hat Enterprise Linux 8 Beta for x86_64 - AppStream (RPMs)
baseurl=file:///mnt/AppStream/
enabled=1
gpgcheck=0
EOF
    dnf_install "java-17-openjdk-headless"
    rm -f ${CONTAINER_PATH}/etc/yum.repos.d/beta.repo
else
    dnf_install "java-17-openjdk-headless tomcat-native apr"
fi

dnf_clean
dnf_clean_cache

clean_files

commit_container base/openjdk17-jre:latest


CONTAINER_UUID=$(create_container base/openjdk17-jre:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}

commit_container openjdk17-jre:latest
