#!/usr/bin/env bash
. ./files/ENV

umask 0022

TMP_DIR=$(mktemp -d)
#tar xvf ../step-ca/files/step_linux_${STEPCLI_VERSION}_amd64.tar.gz -C ${TMP_DIR}
#
#mkdir -vp ${TMP_DIR}/step-ca
#
#VOL_UUID=$(cat /proc/sys/kernel/random/uuid)
#zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID}
#podman volume create\
# --label=deployment=step-ca\
# --label=mountpoint=/var/lib/step-ca\
# --opt=type=zfs\
# --opt=device=${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID}\
# ${VOL_UUID}
#
#mount -t zfs ${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID} ${TMP_DIR}/step-ca
#
#cat /proc/sys/kernel/random/uuid > ${TMP_DIR}/step-ca/root-ca.pass
#cat /proc/sys/kernel/random/uuid > ./files/provisioner.pass
#
#STEPPATH=${TMP_DIR}/step-ca ${TMP_DIR}/step_${STEPCLI_VERSION}/bin/step ca init\
# --deployment-type=standalone\
# --name=${ROOT_CA}\
# --dns=${CA}\
# --address=:443\
# --provisioner=admin\
# --password-file=${TMP_DIR}/step-ca/root-ca.pass\
# --provisioner-password-file=./files//provisioner.pass\
# --with-ca-url=${CA}
#
#TMP_DIR_ESC=$(echo ${TMP_DIR}|sed 's/\//\\\//g')
#sed -i "s/${TMP_DIR_ESC}/\/var\/lib/" ${TMP_DIR}/step-ca/config/defaults.json
#sed -i "s/${TMP_DIR_ESC}/\/var\/lib/" ${TMP_DIR}/step-ca/config/ca.json
#
#umount ${TMP_DIR}/step-ca

podman load -i ./files/pause.tar

#POD_ID=$(date +%y%m%d%H%M)
#podman pod create\
# --infra-image=registry.access.redhat.com/ubi8/pause:8.4\
# --infra-name=step-ca-${POD_ID}-infra\
# --name=step-ca-${POD_ID}\
# --dns-search=lab.skarbek.name\
# --hostname=ca\
# --ip=10.88.0.253\
# --label=deployment=step-ca\
# --label=bootstrap=true
#podman create\
# --pod=step-ca-${POD_ID}\
# --name=step-ca-${POD_ID}-step-ca\
# --volume=${VOL_UUID}:/var/lib/step-ca:z\
# registry.lab.skarbek.name/bootstrap/step-ca:latest

VOL_UUID=$(cat /proc/sys/kernel/random/uuid)
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID}
podman volume create\
 --label=deployment=minio\
 --label=mountpoint=/var/lib/minio\
 --opt=type=zfs\
 --opt=device=${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID}\
 ${VOL_UUID}

POD_ID=$(date +%y%m%d%H%M)
podman pod create\
 --infra-image=registry.access.redhat.com/ubi8/pause:8.4\
 --infra-name=minio-${POD_ID}-infra\
 --name=minio-${POD_ID}\
 --dns-search=lab.skarbek.name\
 --hostname=minio\
 --ip=10.88.0.252\
 --label=deployment=minio\
 --label=bootstrap=true
podman create\
 --pod=minio-${POD_ID}\
 --name=minio-${POD_ID}-minio\
 --volume=${VOL_UUID}:/var/lib/minioa:z\
 registry.lab.skarbek.name/bootstrap/minio:latest

VOL_UUID=$(cat /proc/sys/kernel/random/uuid)
zfs create -o mountpoint=legacy ${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID}
podman volume create\
 --label=deployment=nexus\
 --label=mountpoint=/var/lib/step-ca\
 --opt=type=zfs\
 --opt=device=${ZFS_POOL}/datafs/var/lib/volumes/${VOL_UUID}\
 ${VOL_UUID}