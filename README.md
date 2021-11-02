# RHEL8-based set of container images

## Idea

RHEL8-based containers leveraging `systemd` and its potential including `sysusers.d`, `tmpfiles.d`, eliminating shell scripts inside containers as much as possible.
- Strongly opinionated and totally biased.
- Heavily suffers from NIH syndrome.
- Consul as a config server, `consul-template` as a configuration tool (not yet ;)).

## Build process

Build requires valid Red Hat [subscription](https://developers.redhat.com/) or RHEL 8 as a host, [`podman`](https://github.com/containers/podman/) and [OpenZFS](https://github.com/openzfs/zfs/) as a storage solution for containers and volumes.

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
- `openjdk11-jdk`
- `openjdk11-jre`
- `openjdk17-jdk` - requires RHEL 8.5 Beta repo, script assumes that ISO is mounted on `/mnt`, `maven` drags `java-11-openjdk` with itself, there is no `maven-openjdk17` package yet to prevent that ([#1991521](https://bugzilla.redhat.com/show_bug.cgi?id=1991521))
- `openjdk17-jre` - requires RHEL 8.5 Beta repo, script assumes that ISO is mounted on `/mnt`
- `openjdk8-jdk`
- `openjdk8-jre`
- `openssh`
- `step-ca`
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
- `nodejs14`
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
- `prometheus`
- `python36-devel`
- `python39-devel`
- `rabbitmq`
- `redis6`
- `rekor`
- `rundeck`
- `rust`
- `svn`
- `synth`
- `tempo`
- `vault`
- `vector`
- `zookeeper`
