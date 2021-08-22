dnf -y \
    --installroot=/tmp/dnf_cache \
    --releasever=8.4 \
    --setopt=module_platform_id=platform:el8 \
    --setopt=install_weak_deps=false \
    --nodocs \
    makecache
