#!/usr/bin/env bash

. ./files/ENV

for IMAGE in {openjdk8-jdk,openjdk11-jre,openjdk17-jre,openjdk11-jdk,openjdk17-jdk,nodejs14,nodejs16,golang,rust,python36,python39,ansible,consul,fake-service,kea,knot-dns,knot-resolver,kong,krakend,postgresql13,postgresql14,rabbitmq,redis,tinyproxy,toolbox,vsftpd,yugabytedb}; do
    pushd ../${IMAGE}
        bash -ex ./build.sh
    popd
done
