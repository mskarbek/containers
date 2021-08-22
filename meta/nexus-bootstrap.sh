#!/usr/bin/env bash

NEXUS_URL="http://repo.lab.skarbek.name"

while [ $(curl -s -o /dev/null -w '%{response_code}' -I "${NEXUS_URL}/service/rest/v1/status") != '200' ]; do
    sleep 5
done

OLD_PASS=$(cat files/admin.password)
NEW_PASS=$(cat /proc/sys/kernel/random/uuid)
echo ${NEW_PASS} > files/admin.password.new

curl -s -X 'PUT'\
 "${NEXUS_URL}/service/rest/v1/security/users/admin/change-password"\
 -u admin:${OLD_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: text/plain'\
 -d ${NEW_PASS}

curl -s -X 'PUT' \
 "${NEXUS_URL}/service/rest/v1/security/anonymous"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "enabled": true,
  "userId": "anonymous",
  "realmName": "NexusAuthorizingRealm"
}'

curl -X 'PUT'\
 "${NEXUS_URL}/service/rest/v1/security/realms/active"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '[
  "NexusAuthenticatingRealm",
  "NexusAuthorizingRealm",
  "DockerToken"
]'

curl -s -X 'DELETE'\
 "${NEXUS_URL}/service/rest/v1/repositories/maven-public"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 "${NEXUS_URL}/service/rest/v1/repositories/maven-central"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 "${NEXUS_URL}/service/rest/v1/repositories/maven-releases"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 "${NEXUS_URL}/service/rest/v1/repositories/maven-snapshots"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 "${NEXUS_URL}/service/rest/v1/repositories/nuget-group"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 "${NEXUS_URL}/service/rest/v1/repositories/nuget.org-proxy"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 "${NEXUS_URL}/service/rest/v1/repositories/nuget-hosted"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

REDHAT_PEM=$(curl -s -X 'GET'\
  "${NEXUS_URL}/service/rest/v1/security/ssl?host=cdn.redhat.com&port=443"\
  -u admin:${NEW_PASS}\
  -H 'accept: application/json'|jq -r .pem)

curl -vX 'POST' \
  "${NEXUS_URL}/service/rest/v1/security/ssl/truststore"\
  -u admin:${NEW_PASS}\
  -H 'accept: application/json'\
  -H 'Content-Type: text/plain'\
  -d "${REDHAT_PEM}"

curl -X 'POST'\
 "${NEXUS_URL}/service/rest/v1/repositories/docker/hosted"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "oci-hosted",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true,
    "writePolicy": "ALLOW"
  },
  "cleanup": null,
  "docker": {
    "v1Enabled": false,
    "forceBasicAuth": false,
    "httpPort": 8082,
    "httpsPort": null
  },
  "component": {
    "proprietaryComponents": false
  }
}'

curl -X 'POST'\
 "${NEXUS_URL}/service/rest/v1/repositories/yum/proxy"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "yum-proxy-rhel8-8.4",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true
  },
  "cleanup": null,
  "proxy": {
    "remoteUrl": "https://cdn.redhat.com/content/dist/rhel8/8.4/x86_64/",
    "contentMaxAge": 1440,
    "metadataMaxAge": 180
  },
  "negativeCache": {
    "enabled": true,
    "timeToLive": 1440
  },
  "httpClient": {
    "blocked": false,
    "autoBlock": true,
    "connection": {
      "retries": null,
      "userAgentSuffix": null,
      "timeout": null,
      "enableCircularRedirects": false,
      "enableCookies": false,
      "useTrustStore": true
    },
    "authentication": null
  },
  "routingRuleName": null,
  "yumSigning": null
}'

curl -X 'POST'\
 "${NEXUS_URL}/service/rest/v1/repositories/yum/proxy"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "yum-proxy-rhel8-layered",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true
  },
  "cleanup": null,
  "proxy": {
    "remoteUrl": "https://cdn.redhat.com/content/dist/layered/rhel8/x86_64/",
    "contentMaxAge": 1440,
    "metadataMaxAge": 180
  },
  "negativeCache": {
    "enabled": true,
    "timeToLive": 1440
  },
  "httpClient": {
    "blocked": false,
    "autoBlock": true,
    "connection": {
      "retries": null,
      "userAgentSuffix": null,
      "timeout": null,
      "enableCircularRedirects": false,
      "enableCookies": false,
      "useTrustStore": true
    },
    "authentication": null
  },
  "routingRuleName": null,
  "yumSigning": null
}'

curl -X 'POST'\
 "${NEXUS_URL}/service/rest/v1/repositories/yum/proxy"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "yum-proxy-hyperscale",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true
  },
  "cleanup": null,
  "proxy": {
    "remoteUrl": "http://mirror.centos.org/centos/8-stream/hyperscale/x86_64/",
    "contentMaxAge": 1440,
    "metadataMaxAge": 180
  },
  "negativeCache": {
    "enabled": true,
    "timeToLive": 1440
  },
  "httpClient": {
    "blocked": false,
    "autoBlock": true,
    "connection": null,
    "authentication": null
  },
  "routingRuleName": null,
  "yumSigning": null
}'

curl -X 'POST'\
 "${NEXUS_URL}/service/rest/v1/repositories/yum/proxy"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "yum-proxy-epel",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true
  },
  "cleanup": null,
  "proxy": {
    "remoteUrl": "https://download.fedoraproject.org/pub/epel/8/",
    "contentMaxAge": 1440,
    "metadataMaxAge": 180
  },
  "negativeCache": {
    "enabled": true,
    "timeToLive": 1440
  },
  "httpClient": {
    "blocked": false,
    "autoBlock": true,
    "connection": null,
    "authentication": null
  },
  "routingRuleName": null,
  "yumSigning": null
}'

curl -X 'POST'\
 "${NEXUS_URL}/service/rest/v1/repositories/yum/proxy"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "yum-proxy-elrepo",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true
  },
  "cleanup": null,
  "proxy": {
    "remoteUrl": "https://elrepo.org/linux/elrepo/el8/x86_64/",
    "contentMaxAge": 1440,
    "metadataMaxAge": 180
  },
  "negativeCache": {
    "enabled": true,
    "timeToLive": 1440
  },
  "httpClient": {
    "blocked": false,
    "autoBlock": true,
    "connection": null,
    "authentication": null
  },
  "routingRuleName": null,
  "yumSigning": null
}'
