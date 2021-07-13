zfs create -o mountpoint=legacy f6191baf-fb6c-4937-ba65-8b8bf6b658e1/datafs/var/lib/volumes/240e3b42-e352-11eb-8fe4-c8d9d235d84b
podman volume create --opt type=zfs --opt device=f6191baf-fb6c-4937-ba65-8b8bf6b658e1/datafs/var/lib/volumes/240e3b42-e352-11eb-8fe4-c8d9d235d84b 240e3b42-e352-11eb-8fe4-c8d9d235d84b
#podman run -d --net cni1 --ip 192.168.123.252 --device /dev/zfs:/dev/zfs:rw --cap-add CAP_AUDIT_WRITE -v 240e3b42-e352-11eb-8fe4-c8d9d235d84b:/var/lib/containers:z --name buildah01 10.88.0.252:8082/bootstrap-buildah:2021.07.12-1
podman run -d --net cni1 --ip 192.168.123.252 --privileged -v 240e3b42-e352-11eb-8fe4-c8d9d235d84b:/var/lib/containers:z --name buildah01 10.88.0.252:8082/bootstrap-buildah:2021.07.12-1
podman run -d --net cni1 --ip 192.168.123.253 --name nexus01 10.88.0.252:8082/bootstrap-nexus:2021.07.12-1
