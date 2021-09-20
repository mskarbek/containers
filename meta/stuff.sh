#random shit

sed -i 's/#mount_program = "\/usr\/bin\/fuse-overlayfs"/mount_program = "\/usr\/bin\/fuse-overlayfs"/' ${BUILD_CONTAINER_PATH}/rootfs/etc/containers/storage.conf

rpm -r ${CONTAINER_PATH} -qa --qf '%{NAME}\t%{VERSION}\t%{RELEASE}\n'
