#!/usr/bin/env bash
set -e

cp -v ./.gitlab-ci.yaml ../../mirror-containers/
cp -v ./download-raw.sh ../../mirror-containers/
cp -v ./mirror.sh ../../mirror-containers/

pushd ../../mirror-containers
    git add .
    git commit -m 'chore: mirror update'
    git push
popd
