#!/usr/bin/env bash
set -u

TMP_DIR=$(mktemp -d -p /tmp mirror.XXX)
pushd ${TMP_DIR}
    MIRROR_DIR=$(mktemp -d -p ${TMP_DIR} containers.XXX)
    git clone --quiet https://github.com/mskarbek/containers.git ${MIRROR_DIR}
    for IMAGE in $(ls -1 --hide=README.md --hide=meta ${MIRROR_DIR}); do
        REPO_DIR=$(mktemp -d -p ${TMP_DIR} ${IMAGE}.XXX)
        git clone --quiet git@git.lab.skarbek.name:containers/$IMAGE.git ${REPO_DIR}
        rsync -a --delete --exclude=".git" ${MIRROR_DIR}/${IMAGE}/ ${REPO_DIR}/
        pushd ${REPO_DIR}
            git add .
            git diff-index --cached --quiet HEAD --
            if [ $? -ne 0 ]; then
                git commit -m 'chore: mirror update'
                git push -o ci.skip
            fi
        popd
    done
    #meta is special case
    REPO_DIR=$(mktemp -d -p ${TMP_DIR} meta.XXX)
    git clone --quiet git@git.lab.skarbek.name:containers/meta.git ${REPO_DIR}
    rsync -a --delete --exclude=".git" ${MIRROR_DIR}/meta/{ENV,tag.sh,common.sh} ${REPO_DIR}/
    pushd ${REPO_DIR}
        git add .
        git diff-index --cached --quiet HEAD --
        if [ $? -ne 0 ]; then
            git commit -m 'chore: mirror update'
            git push -o ci.skip
        fi
    popd
popd
rm -rf ${TMP_DIR}
