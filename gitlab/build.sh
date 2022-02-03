. ../meta/common.sh
. ./files/VERSIONS

if [ -z ${GITLAB_TYPE} ] || [ ${GITLAB_TYPE} != "ee" ]; then
    GITLAB_TYPE="ce"
fi

CONTAINER_UUID=$(create_container openssh:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/gitlab-${GITLAB_TYPE}.repo /etc/yum.repos.d/gitlab-${GITLAB_TYPE}.repo
    cp -v ./files/RPM-GPG-KEY-Gitlab /etc/pki/rpm-gpg/RPM-GPG-KEY-Gitlab
fi

dnf_cache
dnf_install "hostname perl policycoreutils policycoreutils-python-utils checkpolicy git"
pushd ./files
    dnf download gitlab-${GITLAB_TYPE}-${GITALB_VERSION}
popd
rpm -ivh --noscripts --root=${CONTAINER_PATH} ./files/gitlab-${GITLAB_TYPE}-${GITALB_VERSION}-*.el8.x86_64.rpm
dnf_clean_cache
dnf_clean

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 gitlab-config.service

buildah config --volume /etc/gitlab ${CONTAINER_UUID}
buildah config --volume /var/log/gitlab ${CONTAINER_UUID}
buildah config --volume /var/opt/gitlab ${CONTAINER_UUID}

commit_container gitlab:latest
