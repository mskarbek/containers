#!/usr/bin/env bash

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-debugsource-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-demo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-demo-fastdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-demo-slowdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-devel-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-devel-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-devel-fastdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-devel-fastdebug-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-devel-slowdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-devel-slowdebug-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-fastdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-fastdebug-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-headless-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-headless-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-headless-fastdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-headless-fastdebug-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-headless-slowdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-headless-slowdebug-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-javadoc-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-javadoc-zip-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-jmods-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-jmods-fastdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-jmods-slowdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-slowdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-slowdebug-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-src-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-src-fastdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-src-slowdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-static-libs-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-static-libs-fastdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org/work/tasks/814/76020814/java-latest-openjdk-static-libs-slowdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    createrepo_c .
popd
echo ${TMP_DIR}
