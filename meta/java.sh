#!/usr/bin/env bash

#VERSION="16.0.2.0.7"
#RELEASE="1"
#
#curl -L -O https://kojipkgs.fedoraproject.org//packages/java-latest-openjdk/${VERSION}/${RELEASE}.rolling.el8/x86_64/java-latest-openjdk-${VERSION}-${RELEASE}.rolling.el8.x86_64.rpm
#
#for PKG in {demo,demo-fastdebug,demo-slowdebug,devel,devel-fastdebug,devel-slowdebug,fastdebug,headless,headless-fastdebug,headless-slowdebug,javadoc,javadoc-zip,jmods,jmods-fastdebug,jmods-slowdebug,slowdebug,src,src-fastdebug,src-slowdebug,static-libs,static-libs-fastdebug,static-libs-slowdebug,debuginfo,debugsource,devel-debuginfo,devel-fastdebug-debuginfo,devel-slowdebug-debuginfo,fastdebug-debuginfo,headless-debuginfo,headless-fastdebug-debuginfo,headless-slowdebug-debuginfo,slowdebug-debuginfo}
#do
#    curl -L -O https://kojipkgs.fedoraproject.org//packages/java-latest-openjdk/${VERSION}/${RELEASE}.rolling.el8/x86_64/java-latest-openjdk-${PKG}-${VERSION}-${RELEASE}.rolling.el8.x86_64.rpm
#done

TMP_DIR=$(mktemp -d)

pushd ${TMP_DIR}
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-debugsource-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-demo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-demo-fastdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-demo-slowdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-devel-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-devel-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-devel-fastdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-devel-fastdebug-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-devel-slowdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-devel-slowdebug-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-fastdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-fastdebug-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-headless-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-headless-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-headless-fastdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-headless-fastdebug-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-headless-slowdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-headless-slowdebug-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-javadoc-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-javadoc-zip-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-jmods-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-jmods-fastdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-jmods-slowdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-slowdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-slowdebug-debuginfo-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-src-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-src-fastdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-src-slowdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-static-libs-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-static-libs-fastdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    curl -L -O https://kojipkgs.fedoraproject.org//work/tasks/814/76020814/java-latest-openjdk-static-libs-slowdebug-17.0.0.0.35-1.rolling.el8.x86_64.rpm
    createrepo_c .
popd

