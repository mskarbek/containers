#!/usr/bin/env bash

buildah config --label architecture- ${CONTAINER_ID}
buildah config --label build-date- ${CONTAINER_ID}
buildah config --label com.redhat.build-host- ${CONTAINER_ID}
buildah config --label com.redhat.component- ${CONTAINER_ID}
buildah config --label com.redhat.license_terms- ${CONTAINER_ID}
buildah config --label description- ${CONTAINER_ID}
buildah config --label distribution-scope- ${CONTAINER_ID}
buildah config --label io.buildah.version- ${CONTAINER_ID}
buildah config --label io.k8s.description- ${CONTAINER_ID}
buildah config --label io.k8s.display-name- ${CONTAINER_ID}
buildah config --label io.openshift.expose-services- ${CONTAINER_ID}
buildah config --label io.openshift.tags- ${CONTAINER_ID}
buildah config --label maintainer- ${CONTAINER_ID}
buildah config --label name- ${CONTAINER_ID}
buildah config --label release- ${CONTAINER_ID}
buildah config --label summary- ${CONTAINER_ID}
buildah config --label url- ${CONTAINER_ID}
buildah config --label vcs-ref- ${CONTAINER_ID}
buildah config --label vcs-type- ${CONTAINER_ID}
buildah config --label vendor- ${CONTAINER_ID}
buildah config --label version- ${CONTAINER_ID}

