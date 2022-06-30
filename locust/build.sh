#!/usr/bin/env bash
set -e

source ../meta/common.sh
source ./files/VERSIONS

container_create base/python3-devel ${1}

# Packages in repos that are unfortunately outdated:
#   python3-click
#   python3-configargparse
#   python3-dataclasses
#   python3-flask
#   python3-flask-cors
#   python3-gevent
#   python3-greenlet
#   python3-importlib-metadata
#   python3-itsdangerous
#   python3-jinja2
#   python3-markupsafe
#   python3-psutil
#   python3-requests
#   python3-typing-extensions
#   python3-werkzeug
#   python3-zipp
#   python3-zmq
# To reduce the image size, we need to properly package locust and all missing deps
dnf_cache
dnf_install "libevent-devel\
 python3-zope-event\
 python3-zope-interface\
 python3-six\
 python3-msgpack\
 python3-certifi\
 python3-brotli\
 python3-charset-normalizer\
 python3-urllib3\
 python3-idna"
dnf_cache_clean
dnf_clean

buildah run --network host ${CONTAINER_UUID} pip3 install locust==${LOCUST_VERSION}

rm -vrf ${CONTAINER_PATH}/root/.cache
rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 locust.service

buildah config --volume /var/lib/locust ${CONTAINER_UUID}
buildah config --cmd '[ "/usr/sbin/init" ]' ${CONTAINER_UUID}
buildah config --stop-signal 'SIGRTMIN+3' ${CONTAINER_UUID}
buildah config --volume /var/log/journal ${CONTAINER_UUID}

container_commit locust ${IMAGE_TAG}
