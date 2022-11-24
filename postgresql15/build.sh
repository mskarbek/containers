#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
if [ ${IMAGE_BOOTSTRAP} == "true" ]; then
    cp -v ./files/pgdg-redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/pgdg-redhat.repo
fi
dnf_install "postgresql15-server postgresql15-contrib citus_15 pg_auto_failover_15 pg_qualstats_15 pg_stat_kcache_15 pg_wait_sampling_15 pg_track_settings_15"
# Not yet in rhel9 repo:
#dnf_install "pgbackrest powa-collector"
dnf_cache_clean
dnf_clean

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 postgresql-15.service

buildah config --volume /var/lib/pgsql/15/data ${CONTAINER_UUID}

container_commit postgresql15 ${IMAGE_TAG}
