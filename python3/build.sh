. ../meta/common.sh

CONTAINER_UUID=$(create_container base:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "python3 python3-pip python3-setuptools python3-wheel python3-pip-wheel python3-setuptools-wheel"
dnf_clean_cache
dnf_clean

commit_container base/python3:latest


CONTAINER_UUID=$(create_container base/python3:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

commit_container python3:latest


CONTAINER_UUID=$(create_container base/python3:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "python3-devel libffi-devel gcc make"
dnf_clean_cache
dnf_clean

commit_container base/python3-devel:latest
