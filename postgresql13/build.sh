. ../meta/functions.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

dnf_module "disable postgresql"
dnf_install "--enablerepo=pgdg-common --enablerepo=pgdg13 postgresql13-server postgresql13-contrib citus_13 pg_auto_failover_13 pg_qualstats_13 pg_stat_kcache_13 pg_wait_sampling_13 pg_track_settings13"

dnf_clean
dnf_clean_cache

buildah run -t ${CONTAINER_UUID} systemctl enable\
 postgresql-13.service

clean_files

commit_container postgres13:latest
