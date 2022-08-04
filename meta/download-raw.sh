#!/usr/bin/env bash
set -u

TXT_YELLOW="\e[1;93m"
TXT_CLEAR="\e[0m"

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

git clone --quiet https://github.com/mskarbek/containers.git ./containers

declare -a ARETFACTS=( "alertmanager" "boundary" "consul" "fake-service" "fleet" "graalvm" "gitlab-runner-buildah" "kuma-cp" "loki" "mimir" "minio" "minio-console" "nexus" "oauth2-proxy" "terraform" "vault" )

pushd ./containers
    for ARETFACT in ${ARETFACTS[@]}; do
        let LENGTH=$(jq length ./${ARETFACT}/files/versions.json)-1
        for (( I=0; I<=${LENGTH}; I++ )); do
            VERSION=$(jq -r .[${I}].version ./${ARETFACT}/files/versions.json)
            curl -s -o /dev/null --fail-with-body -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" $(jq -r .[${I}].local_url ./${ARETFACT}/files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
            if [ ${?} -ne 0 ]; then
                curl -L -O $(jq -r .[${I}].remote_url ./${ARETFACT}/files/versions.json | sed "s;VERSION;${VERSION};g")
                echo -e "${TXT_YELLOW}upload: $(jq -r .[${I}].file_name ./${ARETFACT}/files/versions.json | sed "s;VERSION;${VERSION};")${TXT_CLEAR}"
                curl -s -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" --upload-file $(jq -r .[${I}].file_name ./${ARETFACT}/files/versions.json | sed "s;VERSION;${VERSION};") $(jq -r .[${I}].local_url ./${ARETFACT}/files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RAW_REPO;${REPOSITORY_RAW_REPO};")
            fi
        done
    done
popd

rm -rf ./containers
