ZFS_POOL="a258b6f1-e580-42ea-a79d-c6df33239837"
REGISTRY="10.88.0.249:8082/bootstrap"

#POD_UUID=$(cat /proc/sys/kernel/random/uuid)
#podman run -d --ip 10.88.0.09 --name tinyproxy-${POD_UUID::8} ${REGISTRY}/tinyproxy:2021.08.22-1

POD_UUID=$(cat /proc/sys/kernel/random/uuid)
podman create --ip 10.88.0.10 -p 172.16.0.254:80:80 -p 172.16.0.254:443:443 --name nginx-${POD_UUID::8} ${REGISTRY}/nginx:2021.08.22-1
podman cp ../bootstrap/files/nexus.conf nginx-${POD_UUID::8}:/etc/nginx/conf.d/
podman cp ../bootstrap/files/minio.conf nginx-${POD_UUID::8}:/etc/nginx/conf.d/
podman start nginx-${POD_UUID::8}

VOL_UUID=$(cat /proc/sys/kernel/random/uuid)
POD_UUID=$(cat /proc/sys/kernel/random/uuid)
zfs create -o mountpoint=legacy -o rootcontext="system_u:object_r:container_file_t:s0" ${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID}
podman volume create --opt type=zfs --opt device=${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID} ${VOL_UUID}
podman run -d --ip 10.88.0.11 --name minio-${POD_UUID::8} -v ${VOL_UUID}:/var/lib/minio:z ${REGISTRY}/minio:2021.08.22-1

VOL_UUID=$(cat /proc/sys/kernel/random/uuid)
POD_UUID=$(cat /proc/sys/kernel/random/uuid)
zfs create -o mountpoint=legacy -o rootcontext="system_u:object_r:container_file_t:s0" ${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID}
podman volume create --opt type=zfs --opt device=${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID} ${VOL_UUID}
podman run -d --ip 10.88.0.12 --name nexus-${POD_UUID::8} -v ${VOL_UUID}:/var/lib/sonatype-work:z ${REGISTRY}/nexus:2021.08.22-1
