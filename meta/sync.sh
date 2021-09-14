REPODIR="files/"
mkdir -vp ${REPODIR}

cat << EOF > /etc/yum.repos.d/hyperscale.repo
[hyperscale-main]
name=CentOS 8 Stream - Hyperscale Main
baseurl=http://mirror.centos.org/centos/8-stream/hyperscale/x86_64/packages-main/
enabled=1
gpgcheck=0

[hyperscale-facebook]
name=CentOS 8 Stream - Hyperscale Facebook
baseurl=http://mirror.centos.org/centos/8-stream/hyperscale/x86_64/packages-facebook/
enabled=1
gpgcheck=0
EOF

reposync -p ${REPODIR} --download-metadata --repo=hyperscale-main
reposync -p ${REPODIR} --download-metadata --repo=hyperscale-facebook

rm -vf /etc/yum.repos.d/hyperscale.repo
