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
* [base/openjdk11-jdk](./openjdk10-jdk/README.md)
* [base/openjdk17-jdk](./openjdk17-jdk/README.md)
* [base/openjdk8-jdk](./openjdk8-jdk/README.md)

### runtime-related
* [base/ansible](./ansible/README.md)
* [base/openjdk11-jre](./openjdk10-jre/README.md)
* [base/openjdk17-jre](./openjdk17-jre/README.md)
* [base/openjdk8-jre](./openjdk8-jre/README.md)
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
* [toolbox](./toolbox/README.md)

### services
* [gitlab](./gitlab/README.md)
* [knot-dns](./knot-dns/README.md)
* [knot-resolver](./knot-resolver/README.md)
* [kuma-cp](./kuma-cp/README.md)
* [kuma-dp](./kuma-dp/README.md)
* [kong](./kong/README.md)
* [krakend](./krakend/README.md)
* [nexus](./nexus/README.md)
* [openssh](./openssh/README.md)
* [postgresql14](./postgresql14/README.md)
* [redis](./redis/README.md)
* [yugabytedb](./yugabytedb/README.md)
* [fake-service](./fake-service/README.md)
