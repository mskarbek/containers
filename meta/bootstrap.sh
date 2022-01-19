#!/usr/bin/env bash

. ./files/ENV

for IMAGE in {micro,base,systemd,openssh,gitlab,podman,buildah,gitlab-runner-podman,gitlab-runner-buildah,openjdk8-jre,nexus,minio,nginx,kuma-cp,kuma-dp}; do
    pushd ../${IMAGE}
        bash -ex ./build.sh
    popd
done
