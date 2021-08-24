ZFS_POOL=
REGISTRY=

POD_UUID=$(cat /proc/sys/kernel/random/uuid)
podman run -d --ip 10.88.0.09 --name tinyproxy-${POD_UUID::8} -v ${VOL_UUID}:/var/lib/minio:z ${REGISTRY}/minio:2021.07.19-1

POD_UUID=$(cat /proc/sys/kernel/random/uuid)
podman run -d --ip 10.88.0.10 --name nginx-${POD_UUID::8} -v ${VOL_UUID}:/var/lib/minio:z ${REGISTRY}/minio:2021.07.19-1

VOL_UUID=$(cat /proc/sys/kernel/random/uuid)
POD_UUID=$(cat /proc/sys/kernel/random/uuid)
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID}
podman volume create --opt type=zfs --opt device=${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID} ${VOL_UUID}
podman run -d --ip 10.88.0.11 --name minio-${POD_UUID::8} -v ${VOL_UUID}:/var/lib/minio:z ${REGISTRY}/minio:2021.07.19-1

VOL_UUID=$(cat /proc/sys/kernel/random/uuid)
POD_UUID=$(cat /proc/sys/kernel/random/uuid)
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID}
podman volume create --opt type=zfs --opt device=${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID} ${VOL_UUID}
podman run -d --ip 10.88.0.12 --name nexus-${POD_UUID::8} -v ${VOL_UUID}:/var/lib/minio:z ${REGISTRY}/nexus:2021.07.19-1
