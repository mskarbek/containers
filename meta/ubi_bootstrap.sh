#!/usr/bin/env bash

. ./files/ENV

VOL1_UUID=$(cat /proc/sys/kernel/random/uuid)
VOL2_UUID=$(cat /proc/sys/kernel/random/uuid)
VOL3_UUID=$(cat /proc/sys/kernel/random/uuid)

zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/${VOL1_UUID}
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/${VOL2_UUID}
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/${VOL3_UUID}

podman volume create --opt type=zfs --opt device=${ZFS_POOL}/datafs/var/lib/volumes/${VOL1_UUID} ${VOL1_UUID}
podman volume create --opt type=zfs --opt device=${ZFS_POOL}/datafs/var/lib/volumes/${VOL2_UUID} ${VOL2_UUID}
podman volume create --opt type=zfs --opt device=${ZFS_POOL}/datafs/var/lib/volumes/${VOL3_UUID} ${VOL3_UUID}

podman pull registry.access.redhat.com/ubi8/ubi-init:8.4

podman run -d --name=builder\
 -v ${VOL1_UUID}:/var/lib/containers:z\
 -v ${VOL2_UUID}:/var/lib/volumes:z\
 -v ${VOL3_UUID}:/var/lib/containerd:z\
 -v /home/marcin/projects/envs:/root/projects/envs:z\
 --privileged registry.access.redhat.com/ubi8/ubi-init:8.4

podman exec builder rm -f /etc/rhsm-host /etc/pki/entitlement-host /etc/yum.repos.d/ubi.repo
podman exec builder subscription-manager register --auto-attach --release=8.4 --username=${RHEL_USER} --password=${RHEL_PASS}
podman exec builder dnf -y update
