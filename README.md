# RHEL8-based set of container images

## Idea

RHEL8-based containers leveraging `systemd` and its potential including `sysusers.d`, `tmpfiles.d`, eliminating shell scripts inside containers as much as possible.
- Strongly opinionated and totally biased.
- Heavily suffers from NIH syndrome.
- Consul as a config server, `consul-template` as a configuration tool (not yet ;)).

## Build process

Build requires RHEL 8 with valid [subscription](https://developers.redhat.com/) as a host, `buildah` as a build tool and [ZFS](https://github.com/openzfs/zfs/) as a storage solution for containers and volumes.

To bootstrap a whole set `cd` to the `./meta` dir, copy `ENV` to `./files`, update `./files/ENV` accordingly and run through `bootstrap.0+-.*.sh` scripts.
- `bootstrap.00-host.sh` - makes sure that the host have required ZFS datasets setup properly
- `bootstrap.01-download.sh` - downloads binaries for the minimal set required to properly rebuild the rest
- `bootstrap.02-build.sh` - builds the minimal set using minimal repos set
- `bootstrap.03-start.sh` - starts the minimal set
- `bootstrap.04-rebuild.sh` - rebuilds the minimal set using local proxy (Nexus) with additional repos enabled
- `bootstrap.05-restart.sh` - restarts the minimal set
- `bootstrap.06-all.sh` - builds rest of the set

In the future, this will be converted to the proper Ansible roles/playbooks.

## Meta

`meta` directory contains a set of helper scripts, currently in complete mess.

## Infra

`infra` directory contains deployment playbooks/scripts.

## TODO

Short-term:
- working boostrap script
- proper image versioning
- `consul-template`-based configuration

Long-term:
- self-sufficient CI from bootstrap

## Images

Stable state:
- `micro` - the beginning of everything else
- `base` - expands `micro` with reasonable set of packages
- `systemd` - `base` with systemd as a container command

Working state:
- `fake-service`
- `kafka-all-in-one` - temporary image, will be removed in favor of images with separate components
- `knot-dns`
- `knot-resolver`
- `minio`
- `nexus`
- `nginx`
- `openjdk11-jre`
- `openjdk8-jre`
- `openssh`
- `tinyproxy`
- `toolbox`

WIP state:
- `golang`
- `hazelcast-mc4`
- `hazelcast-mc5`
- `hazelcast4`
- `hazelcast5`
- `jenkins`
- `kea`
- `nodejs10`
- `nodejs14`
- `openjdk11-jdk`
- `openjdk8-jdk`
- `pgadmin4`
- `postgresql13`
- `python36`
- `python39`
- `stork`

Placeholder:
- `389ds`
- `ansible`
- `ara`
- `buildah`
- `concourse`
- `consul`
- `fleet`
- `gitea`
- `grafana`
- `harbor`
- `kafka`
- `keycloak`
- `kong`
- `kowl`
- `kuma-cp`
- `kuma-dp`
- `locust`
- `loki`
- `mysql8`
- `nats`
- `openjdk17-jdk`
- `openjdk17-jre`
- `prometheus`
- `python36-devel`
- `python39-devel`
- `rabbitmq`
- `redis6`
- `rekor`
- `rundeck`
- `rust`
- `step-ca`
- `svn`
- `synth`
- `tempo`
- `vault`
- `vector`
- `zookeeper`
