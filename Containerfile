FROM docker.io/redhat/ubi9:latest

RUN <<EOF
    dnf -y install buildah
    dnf clean all
EOF
