# RHEL-based set of container images
## Idea
RHEL/Alma/CentOS Stream-based containers leveraging `systemd` and its potential including `sysusers.d`, `tmpfiles.d`, eliminating shell scripts inside containers as much as possible. Strongly opinionated.

## Build process
Build requires RHEL 9 (with valid Red Hat [subscription](https://developers.redhat.com/)), Alma Linux 9 or CentOS Stream 9 as a host, Ansible and [`buildah`](https://buildah.io/).

# Images
## Foundation
Those images are intended to replace UBI in their function, but they drop entirely package management from the list of installed packages, so no `dnf` or `rpm`. Instead, all the other containers are built using `buildah` and host `dnf` with `--installroot`.

* [micro](./micro/README.md) - equivalent of `ubi9/ubi-micro`
* [base](./base/README.md) - equivalent of `ubi9/ubi`
* [systemd](./systemd/README.md) - equivalent of `ubi9/ubi-init`

## base-based
### build-related
* [base/golang](./golang/README.md)
* [base/nodejs16-devel](./nodejs16/README.md)
* [base/nodejs18-devel](./nodejs16/README.md)
* [base/openjdk8-jdk](./openjdk8/README.md)
* [base/openjdk11-jdk](./openjdk11/README.md)
* [base/openjdk17-jdk](./openjdk17/README.md)
* [base/python3.9-devel](./python3.9/README.md)
* [base/rust](./rust/README.md)

### runtime-related
* [base/ansible](./ansible/README.md)
* [base/automation](./automation/README.md)
* [base/nodejs16](./nodejs16/README.md)
* [base/nodejs18](./nodejs16/README.md)
* [base/openjdk8-jre](./openjdk8/README.md)
* [base/openjdk11-jre](./openjdk11/README.md)
* [base/openjdk17-jre](./openjdk17/README.md)
* [base/python3.9](./python3.9/README.md)
* [base/terraform](./terraform/README.md)

## systemd-based
### build-related

### runtime-related
* [nodejs16](./nodejs16/README.md)
* [nodejs18](./nodejs16/README.md)
* [openjdk8-jre](./openjdk8/README.md)
* [openjdk11-jre](./openjdk11/README.md)
* [openjdk17-jre](./openjdk17/README.md)
* [python3.9](./python3.9/README.md)

## Refactor:
The below list contains old script-based images dropped after c5c2793414e506b25c12af8ec1ca4d0acd8f1ff3.

## base-based
### build-related
* [base/rpmbuild](./rpmbuild/README.md)

### runtime-related
* [base/toolbox](./toolbox/README.md)

## systemd-based
### build-related
* [buildah-zfs](./buildah/README.md)
* [buildah](./buildah/README.md)
* [gitlab-runner-buildah-zfs](./gitlab-runner/README.md)
* [gitlab-runner-buildah](./gitlab-runner/README.md)
* [gitlab-runner-podman-zfs](./gitlab-runner/README.md)
* [gitlab-runner-podman](./gitlab-runner/README.md)
* [podman-zfs](./podman/README.md)
* [podman](./podman/README.md)

### services
#### development
* [fake-service](./fake-service/README.md)
* [gitlab](./gitlab/README.md)
* [locust](./locust/README.md)
* [nexus](./nexus/README.md)
* [openvscode](./openvscode/README.md)

#### databases
* [consul](./consul/README.md)
* [influxdb](./influxdb/README.md)
* [pgadmin4](./pgadmin4/README.md)
* [postgresql13](./postgresql13/README.md)
* [postgresql14](./postgresql14/README.md)
* [yugabytedb](./yugabytedb/README.md)

#### networking
* [haproxy](./haproxy/README.md)
* [kea](./kea/README.md)
* [knot-dns](./knot-dns/README.md)
* [knot-resolver](./knot-resolver/README.md)
* [krakend](./krakend/README.md)
* [kuma-cp](./kuma-cp/README.md)
* [kuma-dp](./kuma-dp/README.md)
* [nginx](./nginx/README.md)
* [tinyproxy](./tinyproxy/README.md)
* [vsftpd](./vsftpd/README.md)

#### monitoring
* [alertmanager](./alertmanager/README.md)
* [grafana](./grafana/README.md)
* [loki-canary](./loki-canary/README.md)
* [loki](./loki/README.md)
* [prometheus](./prometheus/README.md)
* [pushgateway](./pushgateway/README.md)
* [vector](./vector/README.md)

#### tools
* [ara](./ara/README.md)
* [minio-console](./minio-console/README.md)
* [minio](./minio/README.md)
* [openssh](./openssh/README.md)
* [rundeck-runner](./rundeck-runner/README.md)
* [rundeck](./rundeck/README.md)
* [step-ca](./step-ca/README.md)
* [toolbox](./toolbox/README.md)

#### streaming/messaging
* [nats-kafka](./nats-kafka/README.md)
* [nats](./nats/README.md)
* [rabbitmq](./rabbitmq/README.md)

## TODO
* [apisix](./apisix/README.md)
* [budibase](./budibase/README.md)
* [couchdb](./couchdb/README.md)
* [fleet](./fleet/README.md)
* [harbor](./harbor/README.md)
* [hazelcast-mc4](./hazelcast-mc4/README.md)
* [hazelcast-mc5](./hazelcast-mc5/README.md)
* [hazelcast4](./hazelcast4/README.md)
* [hazelcast5](./hazelcast5/README.md)
* [keycloak](./keycloak/README.md)
* [kowl](./kowl/README.md)
* [mssql](./mssql/README.md)
* [mysql8](./mysql8/README.md)
* [openldap](./openldap/README.md)
* [redis](./redis/README.md)
* [redpanda](./redpanda/README.md)
* [rekor](./rekor/README.md)
* [synth](./synth/README.md)
* [tempo](./tempo/README.md)
* [vault](./vault/README.md)
* [victoriametrics](./victoriametrics/README.md)
* [zookeeper](./zookeeper/README.md)
