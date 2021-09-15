# RHEL8-based set of container images

## Idea

RHEL8-based containers leveraging `systemd` and its potential including `sysusers.d`, `tmpfiles.d`, eliminating shell scripts inside containers as much as possible. Strongly opinionated and totally biased. Heavily suffers from NIH syndrome.

## Build process

Build requires RHEL 8 with valid subscription as a host and `buildah` as a build tool.

## Meta

## Infra

## Images

Final state:
- nothing

Working state:
- base
- fake-service
- kafka-all-in-one - temporary image, will be removed in favor of images with separate components
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
- ansible
- ara
- buildah
- consul
- fleet
- gitea
- grafana
- kafka
- kea
- locust
- loki
- nats
- mysql8
- openjdk11-jdk
- openjdk16-jdk
- openjdk16-jre
- openjdk8-jdk
- prometheus
- python36-devel
- python39-devel
- rabbitmq
- step-ca
- tempo
- vault
- vector
- zookeeper
