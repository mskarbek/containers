#!/usr/bin/env bash

#BUILDAH_VERSION="1.22.3"
#BUILDAH_RELEASE="2.module_el8.5.0+911+f19012f9"
#COCKPIT-PODMAN_VERSION=""
#COCKPIT-PODMAN_RELEASE=""
#CONMON_VERSION="2.0.29"
#CONMON_RELEASE="1.module_el8.5.0+890+6b136101"
#CONTAINER-SELINUX_VERSION=""
#CONTAINER-SELINUX_RELEASE=""
#CONTAINERNETWORKING-PLUGINS_VERSION=""
#CONTAINERNETWORKING-PLUGINS_RELEASE=""
#CONTAINERS-COMMON_VERSION=""
#CONTAINERS-COMMON_RELEASE=""
#CRIU_VERSION=""
#CRIU_RELEASE=""
#CRUN_VERSION=""
#CRUN_RELEASE=""
#FUSE-OVERLAYFS_VERSION=""
#FUSE-OVERLAYFS_RELEASE=""
#LIBSLIRP_VERSION=""
#LIBSLIRP_RELEASE=""
#MODULE-BUILD-MACROS_VERSION=""
#MODULE-BUILD-MACROS_RELEASE=""
#OCI-SECCOMP-BPF-HOOK_VERSION=""
#OCI-SECCOMP-BPF-HOOK_RELEASE=""
#PODMAN_VERSION="3.3.1"
#PODMAN_RELEASE="7.module_el8.5.0+914+45625a54"
#PYTHON-PODMAN_VERSION=""
#PYTHON-PODMAN_RELEASE=""
#RUNC_VERSION=""
#RUNC_RELEASE=""
#SKOPEO_VERSION=""
#SKOPEO_RELEASE=""
#SLIRP4NETNS_VERSION=""
#SLIRP4NETNS_RELEASE=""
#TOOLBOX_VERSION=""
#TOOLBOX_RELEASE=""
#UDICA_VERSION=""
#UDICA_RELEASE=""

curl -L -O https://koji.mbox.centos.org/pkgs/packages/buildah/1.22.3/2.module_el8.5.0+911+f19012f9/x86_64/buildah-1.22.3-2.module_el8.5.0+911+f19012f9.x86_64.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/cockpit-podman/32/2.module_el8.4.0+886+c9a8d9ad/noarch/cockpit-podman-32-2.module_el8.4.0+886+c9a8d9ad.noarch.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/conmon/2.0.29/1.module_el8.5.0+890+6b136101/x86_64/conmon-2.0.29-1.module_el8.5.0+890+6b136101.x86_64.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/container-selinux/2.167.0/1.module_el8.5.0+911+f19012f9/noarch/container-selinux-2.167.0-1.module_el8.5.0+911+f19012f9.noarch.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/containernetworking-plugins/1.0.0/1.module_el8.5.0+890+6b136101/x86_64/containernetworking-plugins-1.0.0-1.module_el8.5.0+890+6b136101.x86_64.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/containers-common/1/2.module_el8.5.0+890+6b136101/noarch/containers-common-1-2.module_el8.5.0+890+6b136101.noarch.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/criu/3.15/3.module_el8.5.0+890+6b136101/x86_64/crit-3.15-3.module_el8.5.0+890+6b136101.x86_64.rpm
curl -L -O https://koji.mbox.centos.org/pkgs/packages/criu/3.15/3.module_el8.5.0+890+6b136101/x86_64/criu-3.15-3.module_el8.5.0+890+6b136101.x86_64.rpm
curl -L -O https://koji.mbox.centos.org/pkgs/packages/criu/3.15/3.module_el8.5.0+890+6b136101/x86_64/criu-devel-3.15-3.module_el8.5.0+890+6b136101.x86_64.rpm
curl -L -O https://koji.mbox.centos.org/pkgs/packages/criu/3.15/3.module_el8.5.0+890+6b136101/x86_64/criu-libs-3.15-3.module_el8.5.0+890+6b136101.x86_64.rpm
curl -L -O https://koji.mbox.centos.org/pkgs/packages/criu/3.15/3.module_el8.5.0+890+6b136101/x86_64/python3-criu-3.15-3.module_el8.5.0+890+6b136101.x86_64.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/crun/1.0/1.module_el8.5.0+911+f19012f9/x86_64/crun-1.0-1.module_el8.5.0+911+f19012f9.x86_64.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/fuse-overlayfs/1.7.1/1.module_el8.5.0+890+6b136101/x86_64/fuse-overlayfs-1.7.1-1.module_el8.5.0+890+6b136101.x86_64.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/libslirp/4.4.0/1.module_el8.5.0+890+6b136101/x86_64/libslirp-4.4.0-1.module_el8.5.0+890+6b136101.x86_64.rpm
curl -L -O https://koji.mbox.centos.org/pkgs/packages/libslirp/4.4.0/1.module_el8.5.0+890+6b136101/x86_64/libslirp-devel-4.4.0-1.module_el8.5.0+890+6b136101.x86_64.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/oci-seccomp-bpf-hook/1.2.3/3.module_el8.5.0+890+6b136101/x86_64/oci-seccomp-bpf-hook-1.2.3-3.module_el8.5.0+890+6b136101.x86_64.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/podman/3.3.1/7.module_el8.5.0+914+45625a54/x86_64/podman-3.3.1-7.module_el8.5.0+914+45625a54.x86_64.rpm
curl -L -O https://koji.mbox.centos.org/pkgs/packages/podman/3.3.1/7.module_el8.5.0+914+45625a54/x86_64/podman-catatonit-3.3.1-7.module_el8.5.0+914+45625a54.x86_64.rpm
curl -L -O https://koji.mbox.centos.org/pkgs/packages/podman/3.3.1/7.module_el8.5.0+914+45625a54/noarch/podman-docker-3.3.1-7.module_el8.5.0+914+45625a54.noarch.rpm
curl -L -O https://koji.mbox.centos.org/pkgs/packages/podman/3.3.1/7.module_el8.5.0+914+45625a54/x86_64/podman-gvproxy-3.3.1-7.module_el8.5.0+914+45625a54.x86_64.rpm
curl -L -O https://koji.mbox.centos.org/pkgs/packages/podman/3.3.1/7.module_el8.5.0+914+45625a54/x86_64/podman-plugins-3.3.1-7.module_el8.5.0+914+45625a54.x86_64.rpm
curl -L -O https://koji.mbox.centos.org/pkgs/packages/podman/3.3.1/7.module_el8.5.0+914+45625a54/x86_64/podman-remote-3.3.1-7.module_el8.5.0+914+45625a54.x86_64.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/python-podman/3.2.0/2.module_el8.5.0+890+6b136101/noarch/python3-podman-3.2.0-2.module_el8.5.0+890+6b136101.noarch.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/runc/1.0.2/1.module_el8.5.0+911+f19012f9/x86_64/runc-1.0.2-1.module_el8.5.0+911+f19012f9.x86_64.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/skopeo/1.4.2/0.1.module_el8.5.0+911+f19012f9/x86_64/skopeo-1.4.2-0.1.module_el8.5.0+911+f19012f9.x86_64.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/slirp4netns/1.1.8/1.module_el8.5.0+890+6b136101/x86_64/slirp4netns-1.1.8-1.module_el8.5.0+890+6b136101.x86_64.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/toolbox/0.0.99.3/0.2.module_el8.5.0+911+f19012f9/x86_64/toolbox-0.0.99.3-0.2.module_el8.5.0+911+f19012f9.x86_64.rpm

curl -L -O https://koji.mbox.centos.org/pkgs/packages/udica/0.2.5/2.module_el8.5.0+913+e4482064/noarch/udica-0.2.5-2.module_el8.5.0+913+e4482064.noarch.rpm
