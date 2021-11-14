#!/usr/bin/env bash
. ./files/ENV

TMP_DIR=$(mktemp -d)
mkdir -vp ${TMP_DIR}/etc/yum.repos.d
mkdir -vp ../{base,minio,nexus,step-ca}/files
mkdir -vp ./files

pushd ${TMP_DIR}
    curl -L -o mcli https://dl.min.io/client/mc/release/linux-amd64/mc
    curl -L -O https://dl.min.io/server/minio/release/linux-amd64/minio
    curl -L -O https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz
    curl -L -O https://github.com/openzfs/zfs/releases/download/zfs-${ZFS_VERSION}/zfs-${ZFS_VERSION}.tar.gz
    curl -L -O https://github.com/smallstep/cli/releases/download/v${STEPCLI_VERSION}/step_linux_${STEPCLI_VERSION}_amd64.tar.gz
    curl -L -O https://github.com/smallstep/certificates/releases/download/v${STEPCA_VERSION}/step-ca_linux_${STEPCA_VERSION}_amd64.tar.gz
popd

rm -vrf ./files/{ubi-init,pause}
mkdir -vp ./files/{ubi-init,pause}
skopeo copy docker://registry.access.redhat.com/ubi8/ubi-init:8.5 dir://$(pwd)/files/ubi-init
skopeo copy docker://registry.access.redhat.com/ubi8/pause:8.5 dir://$(pwd)/files/pause

cat << EOF > ${TMP_DIR}/etc/yum.repos.d/hyperscale.repo
[hyperscale-main]
name=CentOS Stream 8 - Hyperscale Main
baseurl=http://mirror.centos.org/centos/8-stream/hyperscale/x86_64/packages-main/
enabled=1
gpgcheck=0

[hyperscale-facebook]
name=CentOS Stream 8 - Hyperscale Facebook
baseurl=http://mirror.centos.org/centos/8-stream/hyperscale/x86_64/packages-facebook/
enabled=1
gpgcheck=0
EOF

dnf reposync --installroot=${TMP_DIR} --releasever=8 --delete --download-path=../base/files/ --download-metadata --repo=hyperscale-main
dnf reposync --installroot=${TMP_DIR} --releasever=8 --delete --download-path=../base/files/ --download-metadata --repo=hyperscale-facebook

cp -v ${TMP_DIR}/mcli ../minio/files/
cp -v ${TMP_DIR}/minio ../minio/files/
cp -v ${TMP_DIR}/nexus-${NEXUS_VERSION}-unix.tar.gz ../nexus/files/
cp -v ${TMP_DIR}/step_linux_${STEPCLI_VERSION}_amd64.tar.gz ../step-ca/files/
cp -v ${TMP_DIR}/step-ca_linux_${STEPCA_VERSION}_amd64.tar.gz ../step-ca/files/
cp -v ${TMP_DIR}/zfs-${ZFS_VERSION}.tar.gz ./files/

rm -vrf ${TMP_DIR}
