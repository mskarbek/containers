. ../meta/common.sh

CONTAINER_UUID=$(create_container base:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "nodejs npm"
dnf_clean_cache
dnf_clean

commit_container base/nodejs16:latest


CONTAINER_UUID=$(create_container base/nodejs16:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

commit_container nodejs16:latest


CONTAINER_UUID=$(create_container base/nodejs16:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "git-core tar unzip gzip make gcc gcc-c++"
dnf_clean_cache
dnf_clean

commit_container base/nodejs16-devel:latest
