# RHEL-based set of container images
## Idea
RHEL-based containers leveraging `systemd` and its potential including `sysusers.d`, `tmpfiles.d`, eliminating shell scripts inside containers as much as possible. Strongly opinionated. I do not intend to extend support to RHEL rebuilds (AmaLinux/Rocky/whatever). Pretty much every script provided in this repo should "just work" and build a fully functional image based on those RHEL rebuilds (with small adjustments in `meta/common.sh`) but I don't have need nor time to validate that.

## Build process
Build requires valid Red Hat [subscription](https://developers.redhat.com/), RHEL 8 as a host and [`buildah`](https://buildah.io/).
Although [OpenZFS](https://github.com/openzfs/zfs/) is not strictly required, some images take advantage of ZFS and require it to be used as containers (podman, buildah, based on them GitLab runners).

# Images
## Foundation
* [base](./base/README.md)
* [micro](./micro/README.md)
* [systemd](./systemd/README.md)

## base-based
### build-related
* [base/golang](./golang/README.md)
* [base/nodejs14](./nodejs14/README.md)
* [base/nodejs16](./nodejs16/README.md)
* [base/openjdk11-jdk](./openjdk10-jdk/README.md)
* [base/openjdk8-jdk](./openjdk8-jdk/README.md)
* [base/rpmbuild](./rpmbuild/README.md)
* [base/rust](./rust/README.md)

### runtime-related
* [base/ansible](./ansible/README.md)
* [base/openjdk11-jre](./openjdk10-jre/README.md)
* [base/openjdk17-jre](./openjdk17-jre/README.md)
* [base/openjdk8-jre](./openjdk8-jre/README.md)
* [base/python36](./python36/README.md)
* [base/python39](./python39/README.md)
* [base/toolbox](./toolbox/README.md)

## systemd-based
### build-related
* [buildah](./buildah/README.md)
* [gitlab-runner-buildah](./gitlab-runner-buildah/README.md)
* [gitlab-runner-podman](./gitlab-runner-podman/README.md)

### runtime-related
* [openjdk11-jre](./openjdk10-jre/README.md)
* [openjdk17-jre](./openjdk17-jre/README.md)
* [openjdk8-jre](./openjdk8-jre/README.md)
* [podman](./podman/README.md)
* [python36](./python36/README.md)
* [python39](./python39/README.md)
* [toolbox](./toolbox/README.md)

### services
* [consul](./consul/README.md)
* [fake-service](./fake-service/README.md)
* [gitlab](./gitlab/README.md)
* [kea](./kea/README.md)
* [knot-dns](./knot-dns/README.md)
* [knot-resolver](./knot-resolver/README.md)
* [kong](./kong/README.md)
* [krakend](./krakend/README.md)
* [kuma-cp](./kuma-cp/README.md)
* [kuma-dp](./kuma-dp/README.md)
* [minio](./minio/README.md)
* [nexus](./nexus/README.md)
* [nginx](./nginx/README.md)
* [openssh](./openssh/README.md)
* [pgadmin4](./pgadmin4/README.md)
* [postgresql13](./postgresql13/README.md)
* [postgresql14](./postgresql14/README.md)
* [rabbitmq](./rabbitmq/README.md)
* [tinyproxy](./tinyproxy/README.md)
* [vsftpd](./vsftpd/README.md)
* [yugabytedb](./yugabytedb/README.md)

## TODO
* [389ds](./389ds/README.md)
* [ara](./ara/README.md)
* [base/openjdk17-jdk](./openjdk17-jdk/README.md) - needs maven from RHEL 8.6
* [fleet](./fleet/README.md)
* [grafana](./grafana/README.md)
* [harbor](./harbor/README.md)
* [hazelcast-mc4](./hazelcast-mc4/README.md)
* [hazelcast-mc5](./hazelcast-mc5/README.md)
* [hazelcast4](./hazelcast4/README.md)
* [hazelcast5](./hazelcast5/README.md)
* [kafka-all-in-one](./kafka-all-in-one/README.md)
* [kafka](./kafka/README.md)
* [keycloak](./keycloak/README.md)
* [kowl](./kowl/README.md)
* [locust](./locust/README.md)
* [loki](./loki/README.md)
* [mssql](./mssql/README.md)
* [mysql8](./mysql8/README.md)
* [nats](./nats/README.md)
* [prometheus](./prometheus/README.md)
* [python36-devel](./python36-devel/README.md)
* [python39-devel](./python39-devel/README.md)
* [redis](./redis/README.md)
* [rekor](./rekor/README.md)
* [rundeck](./rundeck/README.md)
* [step-ca](./step-ca/README.md)
* [stork](./stork/README.md)
* [svn](./svn/README.md)
* [synth](./synth/README.md)
* [tempo](./tempo/README.md)
* [tidb](./tidb/README.md)
* [vault](./vault/README.md)
* [vector](./vector/README.md)
* [zookeeper](./zookeeper/README.md)
