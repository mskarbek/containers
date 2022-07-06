#!/usr/bin/env bash
set -eu

cat << EOF > ./proxy.repo
[rhel-9-for-x86_64-baseos-rpms]
name = Red Hat Enterprise Linux 9 for x86_64 - BaseOS (RPMs)
baseurl = ${REPOSITORY_URL}/repository/rpm-proxy-rhel/rhel9/9/x86_64/baseos/os
enabled = 1
gpgcheck = 1
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

[rhel-9-for-x86_64-appstream-rpms]
name = Red Hat Enterprise Linux 9 for x86_64 - AppStream (RPMs)
baseurl = ${REPOSITORY_URL}/repository/rpm-proxy-rhel/rhel9/9/x86_64/appstream/os
enabled = 1
gpgcheck = 1
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

[codeready-builder-for-rhel-9-x86_64-rpms]
name = Red Hat CodeReady Linux Builder for RHEL 9 x86_64 (RPMs)
baseurl = ${REPOSITORY_URL}/repository/rpm-proxy-rhel/rhel9/9/x86_64/codeready-builder/os
enabled = 1
gpgcheck = 1
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

[epel]
name = Extra Packages for Enterprise Linux 9 x86_64 (RPMs)
baseurl = ${REPOSITORY_URL}/repository/rpm-proxy-epel/9/Everything/x86_64
enabled = 1
gpgcheck = 1
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9

[rpmfusion-free-updates]
name = RPM Fusion Free for Enterprise Linux 9 x86_64 (RPMs)
baseurl = ${REPOSITORY_URL}/repository/rpm-proxy-rpmfusion/updates/9/x86_64
enabled = 1
gpgcheck = 1
repo_gpgcheck = 0
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-free-el-9
EOF
