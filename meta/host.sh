#/etc/default/grub
#GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=1 psi=1"

grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
setsebool container_manage_cgroup on
