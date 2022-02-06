. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container buildah-zfs:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "openssh-clients git-core hostname"
dnf_clean_cache
dnf_clean

if [ -f "./files/gitlab-runner" ]; then
    mv -v ./files/gitlab-runner ${CONTAINER_PATH}/usr/local/bin/
else
    curl -L -o ${CONTAINER_PATH}/usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/v${GITLAB_RUNNER_VERSION}/binaries/gitlab-runner-linux-amd64
fi
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/*

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 gitlab-runner.service

buildah config --volume /etc/gitlab-runner ${CONTAINER_UUID}
buildah config --volume /var/lib/gitlab-runner ${CONTAINER_UUID}

commit_container gitlab-runner-buildah-zfs:latest
