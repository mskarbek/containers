. ../meta/functions.sh

CONTAINER_UUID=$(cat /proc/sys/kernel/random/uuid)
buildah from --pull-never --name=${CONTAINER_UUID} ${REGISTRY}/systemd:$(date +'%Y.%m.%d')-1
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

dnf_module "disable postgresql"
dnf_install "--enablerepo=pgdg-common --enablerepo=pgdg13 --enablerepo=pgadmin4 libstdc++ pgadmin4-web"

dnf_clean
dnf_clean_cache

clean_files

buildah commit ${CONTAINER_UUID} ${REGISTRY}/pgadmin4:$(date +'%Y.%m.%d')-1
buildah rm -a
