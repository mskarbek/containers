REPODIR="/tmp/d5a37706-e8c9-11eb-89e2-c8d9d235d84b"
mkdir -vp ${REPODIR}

cat << EOF > /etc/yum.repos.d/hyperscale.repo
[hyperscale]
name=CentOS 8 Stream - Hyperscale
baseurl=http://mirror.centos.org/centos/8-stream/hyperscale/x86_64/packages-main/
enabled=1
gpgcheck=0

[hyperscale-facebook]
name=CentOS 8 Stream - Hyperscale Facebook
baseurl=http://mirror.centos.org/centos/8-stream/hyperscale/x86_64/packages-facebook/
enabled=1
gpgcheck=0
EOF

reposync -p ${REPODIR} --download-metadata --repo=hyperscale
reposync -p ${REPODIR} --download-metadata --repo=hyperscale-facebook

rm -vf /etc/yum.repos.d/hyperscale.repo
