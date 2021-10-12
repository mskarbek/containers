#!/usr/bin/env bash

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/buildah/1.22.3/2.module_el8.6.0+926+8bef8ae7/x86_64/buildah-1.22.3-2.module_el8.6.0+926+8bef8ae7.x86_64.rpm
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/conmon/2.0.29/1.module_el8.6.0+926+8bef8ae7/x86_64/conmon-2.0.29-1.module_el8.6.0+926+8bef8ae7.x86_64.rpm
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/container-selinux/2.168.0/2.module_el8.6.0+944+d413f95e/noarch/container-selinux-2.168.0-2.module_el8.6.0+944+d413f95e.noarch.rpm
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/containernetworking-plugins/1.0.0/1.module_el8.6.0+926+8bef8ae7/x86_64/containernetworking-plugins-1.0.0-1.module_el8.6.0+926+8bef8ae7.x86_64.rpm
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/containers-common/1/2.module_el8.6.0+926+8bef8ae7/src/containers-common-1-2.module_el8.6.0+926+8bef8ae7.src.rpm
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/crun/1.0/1.module_el8.6.0+926+8bef8ae7/x86_64/crun-1.0-1.module_el8.6.0+926+8bef8ae7.x86_64.rpm
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/oci-seccomp-bpf-hook/1.2.3/3.module_el8.6.0+926+8bef8ae7/x86_64/oci-seccomp-bpf-hook-1.2.3-3.module_el8.6.0+926+8bef8ae7.x86_64.rpm
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/runc/1.0.2/1.module_el8.6.0+926+8bef8ae7/x86_64/runc-1.0.2-1.module_el8.6.0+926+8bef8ae7.x86_64.rpm
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/skopeo/1.4.2/0.1.module_el8.6.0+926+8bef8ae7/x86_64/skopeo-1.4.2-0.1.module_el8.6.0+926+8bef8ae7.x86_64.rpm
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/podman/3.3.1/9.module_el8.6.0+938+04eb0c17/x86_64/podman-3.3.1-9.module_el8.6.0+938+04eb0c17.x86_64.rpm
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/podman/3.3.1/9.module_el8.6.0+938+04eb0c17/x86_64/podman-catatonit-3.3.1-9.module_el8.6.0+938+04eb0c17.x86_64.rpm
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/podman/3.3.1/9.module_el8.6.0+938+04eb0c17/x86_64/podman-gvproxy-3.3.1-9.module_el8.6.0+938+04eb0c17.x86_64.rpm
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/podman/3.3.1/9.module_el8.6.0+938+04eb0c17/x86_64/podman-plugins-3.3.1-9.module_el8.6.0+938+04eb0c17.x86_64.rpm
    curl -L -O https://koji.mbox.centos.org/pkgs/packages/podman/3.3.1/9.module_el8.6.0+938+04eb0c17/noarch/podman-docker-3.3.1-9.module_el8.6.0+938+04eb0c17.noarch.rpm
popd
echo ${TMP_DIR}
