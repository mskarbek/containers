#!/usr/bin/env bash
set -eu

source ../meta/common.sh

container_create systemd ${1}

dnf_cache
if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/pgdg-redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/pgdg-redhat.repo
fi
dnf_install "postgresql14-server postgresql14-contrib citus_14 pg_auto_failover_14 pg_qualstats_14"
# Not yet in rhel9 repo:
#dnf_install "pg_stat_kcache_14 pg_wait_sampling_14 pg_track_settings_14"
dnf_cache_clean
dnf_clean

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 postgresql-14.service

buildah config --volume /var/lib/pgsql/14/data ${CONTAINER_UUID}

container_commit postgresql14 ${IMAGE_TAG}
