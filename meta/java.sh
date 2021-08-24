VERSION=16.0.2.0.7
RELEASE=1

curl -L -O https://kojipkgs.fedoraproject.org//packages/java-latest-openjdk/${VERSION}/${RELEASE}.rolling.el8/x86_64/java-latest-openjdk-${VERSION}-${RELEASE}.rolling.el8.x86_64.rpm

for PKG in {demo,demo-fastdebug,demo-slowdebug,devel,devel-fastdebug,devel-slowdebug,fastdebug,headless,headless-fastdebug,headless-slowdebug,javadoc,javadoc-zip,jmods,jmods-fastdebug,jmods-slowdebug,slowdebug,src,src-fastdebug,src-slowdebug,static-libs,static-libs-fastdebug,static-libs-slowdebug,debuginfo,debugsource,devel-debuginfo,devel-fastdebug-debuginfo,devel-slowdebug-debuginfo,fastdebug-debuginfo,headless-debuginfo,headless-fastdebug-debuginfo,headless-slowdebug-debuginfo,slowdebug-debuginfo}
do
    curl -L -O https://kojipkgs.fedoraproject.org//packages/java-latest-openjdk/${VERSION}/${RELEASE}.rolling.el8/x86_64/java-latest-openjdk-${PKG}-${VERSION}-${RELEASE}.rolling.el8.x86_64.rpm
done
