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

pushd ./containers
    let LENGTH=$(jq length ./meta/files/versions.json)-1
    for (( I=0; I<=${LENGTH}; I++ )); do
        VERSION=$(jq -r .[${I}].version ./meta/files/versions.json)
        RELEASE=$(jq -r .[${I}].release ./meta/files/versions.json)
        curl -s -o /dev/null --fail-with-body -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" $(jq -r .[${I}].local_url ./meta/files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;RELEASE;${RELEASE};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RPM_REPO;${REPOSITORY_RPM_REPO};")
        if [ ${?} -ne 0 ]; then
            curl -L -O $(jq -r .[${I}].remote_url ./meta/files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;RELEASE;${RELEASE};g")
            echo -e "${TXT_YELLOW}upload: $(jq -r .[${I}].file_name ./meta/files/versions.json | sed "s;VERSION;${VERSION};" | sed "s;RELEASE;${RELEASE};g")${TXT_CLEAR}"
            curl -s -u "${REPOSITORY_USERNAME}:${REPOSITORY_PASSWORD}" --upload-file $(jq -r .[${I}].file_name ./meta/files/versions.json | sed "s;VERSION;${VERSION};") $(jq -r .[${I}].local_url ./meta/files/versions.json | sed "s;VERSION;${VERSION};g" | sed "s;RELEASE;${RELEASE};g" | sed "s;REPOSITORY_URL;${REPOSITORY_URL};" | sed "s;REPOSITORY_RPM_REPO;${REPOSITORY_RPM_REPO};")
        fi
    done
popd

rm -rf ./containers
