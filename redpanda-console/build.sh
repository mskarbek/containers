#!/usr/bin/env bash
set -eu

source ../meta/common.sh
source ./files/VERSIONS

TMP_DIR=$(mktemp -d)
pushd ${TMP_DIR}
    curl -L https://github.com/redpanda-data/console/archive/${REDPANDA_CONSOLE_VERSION}.tar.gz|tar xvz
popd


container_create base/nodejs16-devel latest

FRONTEND_UUID=${CONTAINER_UUID}
FRONTEND_PATH=${CONTAINER_PATH}

webpack_ugly_fix="const crypto = require(\"crypto\");\nconst crypto_orig_createHash = crypto.createHash;\ncrypto.createHash = algorithm => crypto_orig_createHash(algorithm == \"md4\" ? \"sha256\" : algorithm);"

mkdir -vp ${FRONTEND_PATH}/build
rsync -va ${TMP_DIR}/console-${REDPANDA_CONSOLE_VERSION}/frontend/package.json ${FRONTEND_PATH}/build/package.json
rsync -va ${TMP_DIR}/console-${REDPANDA_CONSOLE_VERSION}/frontend/package-lock.json ${FRONTEND_PATH}/build/package-lock.json
rsync -va ${TMP_DIR}/console-${REDPANDA_CONSOLE_VERSION}/frontend/scripts/ ${FRONTEND_PATH}/build/scripts/
buildah run --network host --workingdir /build ${FRONTEND_UUID} npm ci --no-audit
rsync -va ${TMP_DIR}/console-${REDPANDA_CONSOLE_VERSION}/frontend/ ${FRONTEND_PATH}/build/
sed -i "s/'use strict';/'use strict';\n\n${webpack_ugly_fix}/" ${FRONTEND_PATH}/build/node_modules/react-scripts/config/webpack.config.js
buildah run --network host --workingdir /build --env REACT_APP_BUILD_TIMESTAMP=$(date +%s) --env REACT_APP_CONSOLE_GIT_REF=master --env REACT_APP_CONSOLE_GIT_SHA=${REDPANDA_CONSOLE_VERSION} --env REACT_APP_BUILT_FROM_PUSH=flase ${FRONTEND_UUID} npm run build


container_create base/golang latest

BACKEND_UUID=${CONTAINER_UUID}
BACKEND_PATH=${CONTAINER_PATH}

mkdir -vp ${BACKEND_PATH}/build
rsync -va ${TMP_DIR}/console-${REDPANDA_CONSOLE_VERSION}/backend/go.mod ${BACKEND_PATH}/build/go.mod
rsync -va ${TMP_DIR}/console-${REDPANDA_CONSOLE_VERSION}/backend/go.sum ${BACKEND_PATH}/build/go.sum
buildah run --network host --workingdir /build ${BACKEND_UUID} go mod download
rsync -va ${TMP_DIR}/console-${REDPANDA_CONSOLE_VERSION}/backend/ ${BACKEND_PATH}/build/
rsync -va ${FRONTEND_PATH}/build/build/ ${BACKEND_PATH}/build/pkg/embed/frontend/
sed -i 's/all:frontend/frontend\/\*/' ${BACKEND_PATH}/build/pkg/embed/frontend.go
buildah run --network host --workingdir /build --env CGO_ENABLED=0 ${BACKEND_UUID} go build\
 -ldflags="-w -s -X github.com/redpanda-data/console/backend/pkg/version.Version=master-${REDPANDA_CONSOLE_VERSION:0:7}\
 -X github.com/redpanda-data/console/backend/pkg/version.BuiltAt=$(date +%s)"\
 -o ./bin/console ./cmd/api


container_create systemd ${1}

mv -v ${BACKEND_PATH}/build/bin/console ${CONTAINER_PATH}/usr/local/bin/redpanda-console
chmod -v 0755 ${CONTAINER_PATH}/usr/local/bin/redpanda-console

rsync_rootfs

buildah run --network none ${CONTAINER_UUID} systemctl enable\
 redpanda-console.service

buildah config --volume /etc/redpanda-console ${CONTAINER_UUID}

container_commit redpanda-console ${IMAGE_TAG}
