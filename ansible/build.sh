. ../meta/common.sh
. ./files/VERSIONS

CONTAINER_UUID=$(create_container base/python3:latest)
CONTAINER_PATH=$(buildah mount ${CONTAINER_UUID})

dnf_cache
dnf_install "ansible-core openssh-clients git-core rsync python3-requests python3-certifi python3-idna python3-charset-normalizer python3-wcwidth python3-pbr python3-attrs python3-urllib3 python3-prettytable"
dnf_clean_cache
dnf_clean

buildah run -t ${CONTAINER_UUID} pip3 install ara==${ARA_VERSION} python-consul

rm -rvf ${CONTAINER_PATH}/root/.cache

commit_container base/ansible:latest
