#!/usr/bin/env bash

TEMP_ROOT=$(mktemp -d)
mkdir -vp ${TEMP_ROOT}/etc/yum.repos.d
cp -v ../base/files/centos-hyperscale.repo ${TEMP_ROOT}/etc/yum.repos.d/
dnf reposync -n -p ../base/files/ --download-metadata --delete --installroot=${TEMP_ROOT} --releasever=8 --repoid=centos-hyperscale-main
dnf reposync -n -p ../base/files/ --download-metadata --delete --installroot=${TEMP_ROOT} --releasever=8 --repoid=centos-hyperscale-facebook
