. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/systemd:latest
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

dnf_module "disable postgresql"
dnf_install "--enablerepo=pgdg-common --enablerepo=pgdg13 postgresql13-server postgresql13-contrib citus_13 pg_auto_failover_13"

dnf_clean
dnf_clean_cache

buildah run -t ${CONTAINER_UUID} systemctl enable\
 postgresql-13.service

clean_files

buildah commit ${CONTAINER_UUID} ${REGISTRY}/postgres13:latest
buildah rm -a
