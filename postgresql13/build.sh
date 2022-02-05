. ../meta/common.sh

CONTAINER_UUID=$(create_container systemd:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

if [ ! -z ${IMAGE_BOOTSTRAP} ]; then
    cp -v ./files/pgdg-redhat.repo ${CONTAINER_PATH}/etc/yum.repos.d/pgdg-redhat.repo
    cp -v ./files/RPM-GPG-KEY-PGDG /etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG
fi

dnf_cache
dnf_module "disable postgresql"
dnf_install "postgresql13-server postgresql13-contrib citus_13 pg_auto_failover_13 pg_qualstats_13 pg_stat_kcache_13 pg_wait_sampling_13 pg_track_settings13"
dnf_clean_cache
dnf_clean

rsync_rootfs

buildah run -t ${CONTAINER_UUID} systemctl enable\
 postgresql-13.service

buildah config --volume /var/lib/pgsql/13/data ${CONTAINER_UUID}

commit_container postgres13:latest
