#!/usr/bin/env bash
. ./files/ENV

zfs list ${ZFS_POOL}/datafs/var/lib/containers &> /dev/null || {
    zfs list ${ZFS_POOL}/datafs/var/lib &> /dev/null || {
        zfs list ${ZFS_POOL}/datafs/var &> /dev/null || {
            zfs list ${ZFS_POOL}/datafs &> /dev/null || {
                zfs create -o canmount=off -o mountpoint=/ ${ZFS_POOL}/datafs
            }
            zfs create -o canmount=off ${ZFS_POOL}/datafs/var
        }
        zfs create -o canmount=off ${ZFS_POOL}/datafs/var/lib
    }
    zfs create -o canmount=off ${ZFS_POOL}/datafs/var/lib/containers
    restorecon -Rv /var/lib/containers
}

zfs list ${ZFS_POOL}/datafs/var/lib/volumes &> /dev/null || {
    zfs create -o canmount=off ${ZFS_POOL}/datafs/var/lib/volumes
    restorecon -Rv /var/lib/volumes
}
