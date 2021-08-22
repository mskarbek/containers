#for IMG in {micro,base,systemd,nginx,minio,tinyproxy,openjdk8-jre,nexus}; do
for IMG in {micro,base,systemd}; do
    pushd ${IMG}
        time bash -xe build.sh
    popd
done
