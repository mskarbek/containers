#/etc/default/grub
#GRUB_CMDLINE_LINUX="rd.luks.uuid= systemd.unified_cgroup_hierarchy=1 psi=1"
#grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
#setsebool container_manage_cgroup on

zfs create -o mountpoint=legacy f6191baf-fb6c-4937-ba65-8b8bf6b658e1/datafs/var/lib/volumes/240e3b42-e352-11eb-8fe4-c8d9d235d84b
podman volume create --opt type=zfs --opt device=f6191baf-fb6c-4937-ba65-8b8bf6b658e1/datafs/var/lib/volumes/240e3b42-e352-11eb-8fe4-c8d9d235d84b 240e3b42-e352-11eb-8fe4-c8d9d235d84b
podman run -d --network cni1 --ip 192.168.123.1 --name bootstrap01 --privileged -v 240e3b42-e352-11eb-8fe4-c8d9d235d84b:/var/lib/containers:z -v /tmp/id_ed25519.pub:/root/.ssh/authorized_keys 10.88.0.249:8082/bootstrap:2021.07.19-1
