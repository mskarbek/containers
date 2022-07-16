#!/usr/bin/env bash
set -u

TXT_YELLOW="\e[1;93m"
TXT_CLEAR="\e[0m"

TMP_DIR=$(mktemp -d -p /tmp mirror.XXX)
pushd ${TMP_DIR}
    MIRROR_DIR=$(mktemp -d -p ${TMP_DIR} containers.XXX)
    git clone --quiet https://github.com/mskarbek/containers.git ${MIRROR_DIR}
    for IMAGE in $(ls -1 --hide=README.md --hide=meta ${MIRROR_DIR}); do
        REPO_DIR=$(mktemp -d -p ${TMP_DIR} ${IMAGE}.XXX)
        if [ -z ${CI} ]; then
            git clone --quiet git@${GIT_FORGE}:containers/${IMAGE}.git ${REPO_DIR}
        else
            git clone --quiet http://gitlab-ci-token:${CI_JOB_TOKEN}@${GIT_FORGE}/containers/${IMAGE}.git ${REPO_DIR}
        fi
        rsync -a --delete --exclude=".git" ${MIRROR_DIR}/${IMAGE}/ ${REPO_DIR}/
        pushd ${REPO_DIR}
            if [ ! -z ${CI} ]; then
                git config user.name "${GIT_NAME}"
                git config user.email "${GIT_EMAIL}"
                PUSH_URL=`git remote get-url --push origin | sed "s;:\/\/.*@;:\/\/oauth2:${GIT_TOKEN}@;"`
                git remote remove origin
                git remote add origin ${PUSH_URL}
            fi
            git add .
            git diff-index --cached --quiet HEAD --
            if [ ${?} -ne 0 ]; then
                echo -e "${TXT_YELLOW}push: sync changes in ${REPO_DIR}${TXT_CLEAR}"
                git commit -m 'chore: mirror update'
                git push --quiet -o ci.skip -u origin main
            fi
        popd
    done
    #meta is special case
    REPO_DIR=$(mktemp -d -p ${TMP_DIR} meta.XXX)
    if [ -z ${CI} ]; then
        git clone --quiet git@${GIT_FORGE}:containers/meta.git ${REPO_DIR}
    else
        git clone --quiet http://gitlab-ci-token:${CI_JOB_TOKEN}@${GIT_FORGE}/containers/meta.git ${REPO_DIR}
    fi
    rsync -a --delete --exclude=".git" ${MIRROR_DIR}/meta/{ENV,tag.sh,common.sh} ${REPO_DIR}/
    pushd ${REPO_DIR}
        if [ ! -z ${CI} ]; then
            git config user.name "${GIT_NAME}"
            git config user.email "${GIT_EMAIL}"
            PUSH_URL=`git remote get-url --push origin | sed "s;:\/\/.*@;:\/\/oauth2:${GIT_TOKEN}@;"`
            git remote remove origin
            git remote add origin ${PUSH_URL}
        fi
        git add .
        git diff-index --cached --quiet HEAD --
        if [ ${?} -ne 0 ]; then
            echo -e "${TXT_YELLOW}push: sync changes in ${REPO_DIR}${TXT_CLEAR}"
            git commit -m 'chore: mirror update'
            git push --quiet -o ci.skip -u origin main
        fi
    popd
popd
rm -rf ${TMP_DIR}
