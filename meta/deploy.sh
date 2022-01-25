#! /usr/bin/env bash

ZFS_POOL="dfe93b5a-632d-44c4-98b9-7cff969b3a1d"
REGISTRY_URL="registry.lab.skarbek.name"
ORG_URL="lab.skarbek.name"
DEPLOYMENT_ID=$(date +%y%m%d%H%M)
MINIO_ROOT_PASSWORD="password123"
NGINX_ADMIN_PASSWORD="password123"
GITLAB_ROOT_PASSWORD="password123"

podman pod create\
 --infra-image=${REGISTRY_URL}/pause:8.5-1\
 --infra-name=inf-kuma-${DEPLOYMENT_ID}-infra\
 --hostname=inf-kuma-${DEPLOYMENT_ID}\
 --name=inf-kuma-${DEPLOYMENT_ID}\
 --ip=10.88.0.2
podman pod create\
 --infra-image=${REGISTRY_URL}/pause:8.5-1\
 --infra-name=inf-tinyproxy-${DEPLOYMENT_ID}-infra\
 --hostname=inf-tinyproxy-${DEPLOYMENT_ID}\
 --name=inf-tinyproxy-${DEPLOYMENT_ID}\
 --ip=10.88.0.3
podman pod create\
 --infra-image=${REGISTRY_URL}/pause:8.5-1\
 --infra-name=inf-minio-${DEPLOYMENT_ID}-infra\
 --hostname=inf-minio-${DEPLOYMENT_ID}\
 --name=inf-minio-${DEPLOYMENT_ID}\
 --ip=10.88.0.4
podman pod create\
 --infra-image=${REGISTRY_URL}/pause:8.5-1\
 --infra-name=inf-nexus-${DEPLOYMENT_ID}-infra\
 --hostname=inf-nexus-${DEPLOYMENT_ID}\
 --name=inf-nexus-${DEPLOYMENT_ID}\
 --ip=10.88.0.5
podman pod create\
 --infra-image=${REGISTRY_URL}/pause:8.5-1\
 --infra-name=inf-gitlab-${DEPLOYMENT_ID}-infra\
 --hostname=inf-gitlab-${DEPLOYMENT_ID}\
 --name=inf-gitlab-${DEPLOYMENT_ID}\
 --ip=10.88.0.6\
 --publish=2222:22
podman pod create\
 --infra-image=${REGISTRY_URL}/pause:8.5-1\
 --infra-name=inf-nginx-${DEPLOYMENT_ID}-infra\
 --hostname=inf-nginx-${DEPLOYMENT_ID}\
 --name=inf-nginx-${DEPLOYMENT_ID}\
 --ip=10.88.0.7\
 --publish=80:80\
 --publish=443:443

zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-kuma-${DEPLOYMENT_ID}-app-etc
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-kuma-${DEPLOYMENT_ID}-app-log
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-tinyproxy-${DEPLOYMENT_ID}-app-etc
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-minio-${DEPLOYMENT_ID}-app-lib
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-nexus-${DEPLOYMENT_ID}-app-lib
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-gitlab-${DEPLOYMENT_ID}-app-etc
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-gitlab-${DEPLOYMENT_ID}-app-opt
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-gitlab-${DEPLOYMENT_ID}-app-log
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-nginx-${DEPLOYMENT_ID}-app-etc

zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-kuma-${DEPLOYMENT_ID}-mesh-etc
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-kuma-${DEPLOYMENT_ID}-mesh-log
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-tinyproxy-${DEPLOYMENT_ID}-mesh-etc
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-tinyproxy-${DEPLOYMENT_ID}-mesh-log
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-minio-${DEPLOYMENT_ID}-mesh-etc
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-minio-${DEPLOYMENT_ID}-mesh-log
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-nexus-${DEPLOYMENT_ID}-mesh-etc
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-nexus-${DEPLOYMENT_ID}-mesh-log
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-gitlab-${DEPLOYMENT_ID}-mesh-etc
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-gitlab-${DEPLOYMENT_ID}-mesh-log
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-nginx-${DEPLOYMENT_ID}-mesh-etc
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-nginx-${DEPLOYMENT_ID}-mesh-log

VOLS=(inf-kuma-${DEPLOYMENT_ID}-app-etc)
VOLS+=(inf-tinyproxy-${DEPLOYMENT_ID}-app-etc)
VOLS+=(inf-gitlab-${DEPLOYMENT_ID}-app-etc)
VOLS+=(inf-nginx-${DEPLOYMENT_ID}-app-etc)
VOLS+=(inf-kuma-${DEPLOYMENT_ID}-mesh-etc)
VOLS+=(inf-tinyproxy-${DEPLOYMENT_ID}-mesh-etc)
VOLS+=(inf-minio-${DEPLOYMENT_ID}-mesh-etc)
VOLS+=(inf-nexus-${DEPLOYMENT_ID}-mesh-etc)
VOLS+=(inf-gitlab-${DEPLOYMENT_ID}-mesh-etc)
VOLS+=(inf-nginx-${DEPLOYMENT_ID}-mesh-etc)

TMP_MOUNT=$(mktemp -d)
for VOL in ${VOLS[@]}; do
    mkdir ${TMP_MOUNT}/${VOL}
    mount -t zfs ${ZFS_POOL}/datafs/var/lib/volumes/storage/${VOL} ${TMP_MOUNT}/${VOL}
done

cp ./files/mesh-inf.yaml ${TMP_MOUNT}/inf-kuma-${DEPLOYMENT_ID}-app-etc/mesh-inf.yaml
cp ./files/traffic-log-inf.yaml ${TMP_MOUNT}/inf-kuma-${DEPLOYMENT_ID}-app-etc/traffic-log-inf.yaml
cp ./files/tinyproxy.conf ${TMP_MOUNT}/inf-tinyproxy-${DEPLOYMENT_ID}-app-etc/tinyproxy.conf
cp ./files/gitlab.rb ${TMP_MOUNT}/inf-gitlab-${DEPLOYMENT_ID}-app-etc/gitlab.rb
sed -i "s/ORG_URL/${ORG_URL}/g" ${TMP_MOUNT}/inf-gitlab-${DEPLOYMENT_ID}-app-etc/gitlab.rb
cp ./files/ingress.conf ${TMP_MOUNT}/inf-nginx-${DEPLOYMENT_ID}-app-etc/ingress.conf
sed -i "s/ORG_URL/${ORG_URL}/g" ${TMP_MOUNT}/inf-nginx-${DEPLOYMENT_ID}-app-etc/ingress.conf
cp ./files/dataplane-kuma.yaml ${TMP_MOUNT}/inf-kuma-${DEPLOYMENT_ID}-mesh-etc/dataplane.yaml
sed -i "s/DEPLOYMENT_ID/${DEPLOYMENT_ID}/" ${TMP_MOUNT}/inf-kuma-${DEPLOYMENT_ID}-mesh-etc/dataplane.yaml
cp ./files/dataplane-tinyproxy.yaml ${TMP_MOUNT}/inf-tinyproxy-${DEPLOYMENT_ID}-mesh-etc/dataplane.yaml
sed -i "s/DEPLOYMENT_ID/${DEPLOYMENT_ID}/" ${TMP_MOUNT}/inf-tinyproxy-${DEPLOYMENT_ID}-mesh-etc/dataplane.yaml
cp ./files/dataplane-minio.yaml ${TMP_MOUNT}/inf-minio-${DEPLOYMENT_ID}-mesh-etc/dataplane.yaml
sed -i "s/DEPLOYMENT_ID/${DEPLOYMENT_ID}/" ${TMP_MOUNT}/inf-minio-${DEPLOYMENT_ID}-mesh-etc/dataplane.yaml
cp ./files/dataplane-nexus.yaml ${TMP_MOUNT}/inf-nexus-${DEPLOYMENT_ID}-mesh-etc/dataplane.yaml
sed -i "s/DEPLOYMENT_ID/${DEPLOYMENT_ID}/" ${TMP_MOUNT}/inf-nexus-${DEPLOYMENT_ID}-mesh-etc/dataplane.yaml
cp ./files/dataplane-gitlab.yaml ${TMP_MOUNT}/inf-gitlab-${DEPLOYMENT_ID}-mesh-etc/dataplane.yaml
sed -i "s/DEPLOYMENT_ID/${DEPLOYMENT_ID}/" ${TMP_MOUNT}/inf-gitlab-${DEPLOYMENT_ID}-mesh-etc/dataplane.yaml
cp ./files/dataplane-nginx.yaml ${TMP_MOUNT}/inf-nginx-${DEPLOYMENT_ID}-mesh-etc/dataplane.yaml
sed -i "s/DEPLOYMENT_ID/${DEPLOYMENT_ID}/" ${TMP_MOUNT}/inf-nginx-${DEPLOYMENT_ID}-mesh-etc/dataplane.yaml

for VOL in ${VOLS[@]}; do
    umount ${TMP_MOUNT}/${VOL}
    rmdir ${TMP_MOUNT}/${VOL}
done
rmdir ${TMP_MOUNT}

podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-kuma-${DEPLOYMENT_ID}-app-etc" inf-kuma-${DEPLOYMENT_ID}-app-etc
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-kuma-${DEPLOYMENT_ID}-app-log" inf-kuma-${DEPLOYMENT_ID}-app-log
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-tinyproxy-${DEPLOYMENT_ID}-app-etc" inf-tinyproxy-${DEPLOYMENT_ID}-app-etc
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-minio-${DEPLOYMENT_ID}-app-lib" inf-minio-${DEPLOYMENT_ID}-app-lib
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-nexus-${DEPLOYMENT_ID}-app-lib" inf-nexus-${DEPLOYMENT_ID}-app-lib
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-gitlab-${DEPLOYMENT_ID}-app-etc" inf-gitlab-${DEPLOYMENT_ID}-app-etc
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-gitlab-${DEPLOYMENT_ID}-app-opt" inf-gitlab-${DEPLOYMENT_ID}-app-opt
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-gitlab-${DEPLOYMENT_ID}-app-log" inf-gitlab-${DEPLOYMENT_ID}-app-log
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-nginx-${DEPLOYMENT_ID}-app-etc" inf-nginx-${DEPLOYMENT_ID}-app-etc

podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-kuma-${DEPLOYMENT_ID}-mesh-etc" inf-kuma-${DEPLOYMENT_ID}-mesh-etc
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-kuma-${DEPLOYMENT_ID}-mesh-log" inf-kuma-${DEPLOYMENT_ID}-mesh-log
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-tinyproxy-${DEPLOYMENT_ID}-mesh-etc" inf-tinyproxy-${DEPLOYMENT_ID}-mesh-etc
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-tinyproxy-${DEPLOYMENT_ID}-mesh-log" inf-tinyproxy-${DEPLOYMENT_ID}-mesh-log
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-minio-${DEPLOYMENT_ID}-mesh-etc" inf-minio-${DEPLOYMENT_ID}-mesh-etc
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-minio-${DEPLOYMENT_ID}-mesh-log" inf-minio-${DEPLOYMENT_ID}-mesh-log
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-nexus-${DEPLOYMENT_ID}-mesh-etc" inf-nexus-${DEPLOYMENT_ID}-mesh-etc
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-nexus-${DEPLOYMENT_ID}-mesh-log" inf-nexus-${DEPLOYMENT_ID}-mesh-log
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-gitlab-${DEPLOYMENT_ID}-mesh-etc" inf-gitlab-${DEPLOYMENT_ID}-mesh-etc
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-gitlab-${DEPLOYMENT_ID}-mesh-log" inf-gitlab-${DEPLOYMENT_ID}-mesh-log
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-nginx-${DEPLOYMENT_ID}-mesh-etc" inf-nginx-${DEPLOYMENT_ID}-mesh-etc
podman volume create -o "type=zfs" -o "device=${ZFS_POOL}/datafs/var/lib/volumes/storage/inf-nginx-${DEPLOYMENT_ID}-mesh-log" inf-nginx-${DEPLOYMENT_ID}-mesh-log

podman run\
 --detach\
 --pod=inf-kuma-${DEPLOYMENT_ID}\
 --name=inf-kuma-${DEPLOYMENT_ID}-app\
 --volume=inf-kuma-${DEPLOYMENT_ID}-app-etc:/etc/kuma/config:z\
 --volume=inf-kuma-${DEPLOYMENT_ID}-app-log:/var/log/kuma:z\
 ${REGISTRY_URL}/bootstrap/kuma-cp:latest

sleep 10
podman exec inf-kuma-${DEPLOYMENT_ID}-app kumactl apply -f /etc/kuma/config/mesh-inf.yaml 
podman exec inf-kuma-${DEPLOYMENT_ID}-app kumactl apply -f /etc/kuma/config/traffic-log-inf.yaml

mkdir -p /run/.kuma
podman exec inf-kuma-${DEPLOYMENT_ID}-app kumactl generate dataplane-token --mesh=inf --name=inf-kuma-${DEPLOYMENT_ID} > /run/.kuma/inf-kuma-${DEPLOYMENT_ID}.token
podman exec inf-kuma-${DEPLOYMENT_ID}-app kumactl generate dataplane-token --mesh=inf --name=inf-tinyproxy-${DEPLOYMENT_ID} > /run/.kuma/inf-tinyproxy-${DEPLOYMENT_ID}.token
podman exec inf-kuma-${DEPLOYMENT_ID}-app kumactl generate dataplane-token --mesh=inf --name=inf-minio-${DEPLOYMENT_ID} > /run/.kuma/inf-minio-${DEPLOYMENT_ID}.token
podman exec inf-kuma-${DEPLOYMENT_ID}-app kumactl generate dataplane-token --mesh=inf --name=inf-nexus-${DEPLOYMENT_ID} > /run/.kuma/inf-nexus-${DEPLOYMENT_ID}.token
podman exec inf-kuma-${DEPLOYMENT_ID}-app kumactl generate dataplane-token --mesh=inf --name=inf-gitlab-${DEPLOYMENT_ID} > /run/.kuma/inf-gitlab-${DEPLOYMENT_ID}.token
podman exec inf-kuma-${DEPLOYMENT_ID}-app kumactl generate dataplane-token --mesh=inf --name=inf-nginx-${DEPLOYMENT_ID} > /run/.kuma/inf-nginx-${DEPLOYMENT_ID}.token

printf "KUMA_CP_ADDRESS=https://10.88.0.2:5678/\n"|podman secret create kuma-config -

podman run\
 --detach\
 --pod=inf-kuma-${DEPLOYMENT_ID}\
 --name=inf-kuma-${DEPLOYMENT_ID}-mesh\
 --volume=inf-kuma-${DEPLOYMENT_ID}-mesh-etc:/etc/kuma:z\
 --volume=inf-kuma-${DEPLOYMENT_ID}-mesh-log:/var/log/kuma:z\
 --volume=/run/.kuma/inf-kuma-${DEPLOYMENT_ID}.token:/run/secrets/kuma-token:z\
 --secret=kuma-config,type=mount\
 ${REGISTRY_URL}/bootstrap/kuma-dp:latest
podman run\
 --detach\
 --pod=inf-tinyproxy-${DEPLOYMENT_ID}\
 --name=inf-tinyproxy-${DEPLOYMENT_ID}-mesh\
 --volume=inf-tinyproxy-${DEPLOYMENT_ID}-mesh-etc:/etc/kuma:z\
 --volume=inf-tinyproxy-${DEPLOYMENT_ID}-mesh-log:/var/log/kuma:z\
 --volume=/run/.kuma/inf-tinyproxy-${DEPLOYMENT_ID}.token:/run/secrets/kuma-token:z\
 --secret=kuma-config,type=mount\
 ${REGISTRY_URL}/bootstrap/kuma-dp:latest
podman run\
 --detach\
 --pod=inf-minio-${DEPLOYMENT_ID}\
 --name=inf-minio-${DEPLOYMENT_ID}-mesh\
 --volume=inf-minio-${DEPLOYMENT_ID}-mesh-etc:/etc/kuma:z\
 --volume=inf-minio-${DEPLOYMENT_ID}-mesh-log:/var/log/kuma:z\
 --volume=/run/.kuma/inf-minio-${DEPLOYMENT_ID}.token:/run/secrets/kuma-token:z\
 --secret=kuma-config,type=mount\
 ${REGISTRY_URL}/bootstrap/kuma-dp:latest
podman run\
 --detach\
 --pod=inf-nexus-${DEPLOYMENT_ID}\
 --name=inf-nexus-${DEPLOYMENT_ID}-mesh\
 --volume=inf-nexus-${DEPLOYMENT_ID}-mesh-etc:/etc/kuma:z\
 --volume=inf-nexus-${DEPLOYMENT_ID}-mesh-log:/var/log/kuma:z\
 --volume=/run/.kuma/inf-nexus-${DEPLOYMENT_ID}.token:/run/secrets/kuma-token:z\
 --secret=kuma-config,type=mount\
 ${REGISTRY_URL}/bootstrap/kuma-dp:latest
podman run\
 --detach\
 --pod=inf-gitlab-${DEPLOYMENT_ID}\
 --name=inf-gitlab-${DEPLOYMENT_ID}-mesh\
 --volume=inf-gitlab-${DEPLOYMENT_ID}-mesh-etc:/etc/kuma:z\
 --volume=inf-gitlab-${DEPLOYMENT_ID}-mesh-log:/var/log/kuma:z\
 --volume=/run/.kuma/inf-gitlab-${DEPLOYMENT_ID}.token:/run/secrets/kuma-token:z\
 --secret=kuma-config,type=mount\
 ${REGISTRY_URL}/bootstrap/kuma-dp:latest
podman run\
 --detach\
 --pod=inf-nginx-${DEPLOYMENT_ID}\
 --name=inf-nginx-${DEPLOYMENT_ID}-mesh\
 --volume=inf-nginx-${DEPLOYMENT_ID}-mesh-etc:/etc/kuma:z\
 --volume=inf-nginx-${DEPLOYMENT_ID}-mesh-log:/var/log/kuma:z\
 --volume=/run/.kuma/inf-nginx-${DEPLOYMENT_ID}.token:/run/secrets/kuma-token:z\
 --secret=kuma-config,type=mount\
 ${REGISTRY_URL}/bootstrap/kuma-dp:latest

printf "MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}\n"|podman secret create minio-root-password -
printf "NEXUS_PASSWORD=${NGINX_ADMIN_PASSWORD}\n"|podman secret create nexus-password -
printf "GITLAB_ROOT_PASSWORD=${GITLAB_ROOT_PASSWORD}\n"|podman secret create gitlab-password -

podman run\
 --detach\
 --pod=inf-tinyproxy-${DEPLOYMENT_ID}\
 --name=inf-tinyproxy-${DEPLOYMENT_ID}-app\
 --volume=inf-tinyproxy-${DEPLOYMENT_ID}-app-etc:/etc/tinyproxy:z\
 ${REGISTRY_URL}/bootstrap/tinyproxy:latest
podman run\
 --detach\
 --pod=inf-minio-${DEPLOYMENT_ID}\
 --name=inf-minio-${DEPLOYMENT_ID}-app\
 --volume=inf-minio-${DEPLOYMENT_ID}-app-lib:/var/lib/minio:z\
 --secret=minio-root-password,type=mount\
 ${REGISTRY_URL}/bootstrap/minio:latest
podman run\
 --detach\
 --pod=inf-nexus-${DEPLOYMENT_ID}\
 --name=inf-nexus-${DEPLOYMENT_ID}-app\
 --volume=inf-nexus-${DEPLOYMENT_ID}-app-lib:/var/lib/sonatype-work:z\
 --secret=nexus-password,type=mount\
 ${REGISTRY_URL}/bootstrap/nexus:latest
podman run\
 --detach\
 --pod=inf-gitlab-${DEPLOYMENT_ID}\
 --name=inf-gitlab-${DEPLOYMENT_ID}-app\
 --volume=inf-gitlab-${DEPLOYMENT_ID}-app-etc:/etc/gitlab:z\
 --volume=inf-gitlab-${DEPLOYMENT_ID}-app-opt:/var/opt/gitlab:z\
 --volume=inf-gitlab-${DEPLOYMENT_ID}-app-log:/var/log/gitlab:z\
 --secret=gitlab-password,type=mount\
 ${REGISTRY_URL}/bootstrap/gitlab:latest
podman run\
 --detach\
 --pod=inf-nginx-${DEPLOYMENT_ID}\
 --name=inf-nginx-${DEPLOYMENT_ID}-app\
 --volume=inf-nginx-${DEPLOYMENT_ID}-app-etc:/etc/nginx/conf.d:z\
 ${REGISTRY_URL}/bootstrap/nginx:latest
