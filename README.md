# RHEL8-based set of container images

## Idea

RHEL8-based containers leveraging `systemd` and its potential including `sysusers.d`, `tmpfiles.d`, eliminating shell scripts inside containers as much as possible.
- Strongly opinionated and totally biased.
- Heavily suffers from NIH syndrome.
- Consul as a config server, `consul-template` as a configuration tool.

## Build process

Build requires RHEL 8 with valid subscription as a host and `buildah` as a build tool.

## Meta

`meta` directory contains a set of helper scripts, currently in complete mess.

## Infra

`infra` directory contains deployment playbooks/scripts.

## TODO

Short-term:
- working boostrap script
- proper image versioning

Long-term:
- self-sufficient CI from bootstrap

## Images

Stable state:
- nothing

Working state:
- base
- fake-service
- kafka-all-in-one - temporary image, will be removed in favor of images with separate components
- micro
- minio
- nexus
- nginx
- openjdk11-jdk
- openjdk11-jre
- openjdk17-jdk
- openjdk17-jre
- openjdk8-jdk
- openjdk8-jre
- openssh
- systemd
- tinyproxy
- toolbox

WIP state:
- golang
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
- 389ds
- ansible
- ara
- buildah
- concourse
- consul
- fleet
- gitea
- grafana
- harbor
- kafka
- kea
- keycloak
- kong
- kowl
- kuma-cp
- kuma-dp
- locust
- loki
- mysql8
- nats
- prometheus
- python36-devel
- python39-devel
- rabbitmq
- redis6
- rekor
- rundeck
- rust
- step-ca
- svn
- synth
- tempo
- vault
- vector
- zookeeper
