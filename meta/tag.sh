#!/usr/bin/env bash

LAST_TAG=$(git tag --list v*|sort|tail -n 1)

if [ -z ${LAST_TAG} ]; then
    TAG=$(date +%y.%m-1)
else
    LAST_TAG_YEAR=$(echo ${LAST_TAG} | awk -F . '{print $1}')
    LAST_TAG_MONTH=$(echo ${LAST_TAG} | awk -F . '{print $2}' | awk -F - '{print $1}')
    LAST_TAG_BUILD=$(echo ${LAST_TAG} | awk -F . '{print $2}' | awk -F - '{print $2}')
    if [ $(date +v%y) != ${LAST_TAG_YEAR} ]; then
        TAG=$(date +%y.%m-1)
    else
        if [ $(date +%m) != ${LAST_TAG_MONTH} ]; then
            TAG=$(date +%y.%m-1)
        else
            TAG_BUILD=$((LAST_TAG_BUILD+1))
            TAG=$(date +%y.%m-${TAG_BUILD})
        fi
    fi
fi

printf ${TAG}
