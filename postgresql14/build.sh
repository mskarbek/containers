. ../meta/functions.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache

dnf_module "disable postgresql"
dnf_install "--enablerepo=pgdg-common --enablerepo=pgdg14 postgresql14-server postgresql14-contrib citus_14 pg_auto_failover_14 pg_qualstats_14 pg_stat_kcache_14 pg_wait_sampling_14 pg_track_settings_14"

dnf_clean
dnf_clean_cache

buildah run -t ${CONTAINER_UUID} systemctl enable\
 postgresql-14.service

clean_files

commit_container postgres14:latest
