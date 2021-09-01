#!/usr/bin/env bash

VERSION="3.3.1"
RELEASE="7.module_el8.5.0+914+45625a54"

curl -L -O https://koji.mbox.centos.org/pkgs/packages/podman/${VERSION}/${RELEASE}/x86_64/podman-${VERSION}-${RELEASE}.x86_64.rpm
curl -L -O https://koji.mbox.centos.org/pkgs/packages/podman/${VERSION}/${RELEASE}/noarch/podman-docker-${VERSION}-${RELEASE}.noarch.rpm

for PKG in {catatonit,gvproxy,plugins,remote,tests,catatonit-debuginfo,debuginfo,debugsource,gvproxy-debuginfo,plugins-debuginfo,remote-debuginfo}
do
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/podman/${VERSION}/${RELEASE}/x86_64/podman-${PKG}-${VERSION}-${RELEASE}.x86_64.rpm
done
