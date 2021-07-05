REGISTRY='10.88.0.1:8082'

CONTAINER_ID=$(buildah from ${REGISTRY}/base:$(date +'%Y.%m.%d')-1)

buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_ID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_ID}

buildah commit ${CONTAINER_ID} ${REGISTRY}/systemd:$(date +'%Y.%m.%d')-1
buildah rm -a
