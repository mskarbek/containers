#!/usr/bin/env bash
. ./files/ENV

rpm -q zfs &> /dev/null && rpm -q skopeo &> /dev/null && rpm -q podman &> /dev/null && rpm -q ansible &> /dev/null || {
    echo "Missing packages. Make sure that you have installed zfs, skopeo and podman, ansible."
    exit 1
}

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
    zfs create ${ZFS_POOL}/datafs/var/lib/containers
    zfs create ${ZFS_POOL}/datafs/var/lib/containers/storage
    restorecon -Rv /var/lib/containers
}

zfs list ${ZFS_POOL}/datafs/var/lib/volumes &> /dev/null || {
    zfs create ${ZFS_POOL}/datafs/var/lib/volumes
    zfs create ${ZFS_POOL}/datafs/var/lib/volumes/storage
    restorecon -Rv /var/lib/volumes
}

cp -v /usr/share/containers/containers.conf /etc/containers/containers.conf
sed -i 's/#volume_path = "\/var\/lib\/containers\/storage\/volumes"/volume_path = "\/var\/lib\/volumes\/storage"/' /etc/containers/containers.conf
sed -i 's/driver = "overlay"/driver = "zfs"/' /etc/containers/storage.conf

setsebool container_manage_cgroup on

grep "systemd.unified_cgroup_hierarchy=1" /etc/default/grub || {
    sed -i 's/\(GRUB_CMDLINE_LINUX="\)\(.*\)\("\)/\1\2systemd.unified_cgroup_hierarchy=1 \3/' /etc/default/grub
    grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
}

grep "psi=1" /etc/default/grub || {
    sed -i 's/\(GRUB_CMDLINE_LINUX="\)\(.*\)\("\)/\1\2 psi=1 \3/' /etc/default/grub
    grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
}
