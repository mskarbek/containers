. ../meta/common.sh

if [ -z ${1} ]; then
    CONTAINER_UUID=$(create_container base latest)
else
    CONTAINER_UUID=$(create_container base ${1})
fi
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

commit_container systemd $SYSTEMD_TAG
