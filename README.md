# RHEL8-based set of container images

## Idea

RHEL8-based containers leveraging `systemd` and its potential including `sysusers.d`, `tmpfiles.d`, eliminating shell scripts inside containers as much as possible. Strongly opinionated and totally biased.

`buildah` as a build tool.

## Images

Final state:
- nothing

Working state:
- base
- micro
- minio
- nexus
- nginx
- openjdk11-jre
- openjdk8-jre
- openssh
- systemd
- tinyproxy

WIP state:
- fake-service
- jenkins
- knot-dns
- knot-resolver
- nodejs10
- nodejs14
- pgadmin4
- postgresql13
- python36
- python39

Placeholder:
- ara
- buildah
- consul
- kea
- locust
- mysql8
- openjdk11-jdk
- openjdk16-jdk
- openjdk16-jre
- openjdk8-jdk
- python36-devel
- python39-devel
- step-ca
- vault
