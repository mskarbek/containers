#!/usr/bin/env bash

if [ -f /var/lib/sonatype-work/nexus3/.lock ]; then
    rm -f /var/lib/sonatype-work/nexus3/admin.password.new
    exit 0
fi

while [ $(curl -s -o /dev/null -w '%{response_code}' -I http://127.0.0.1:8081/service/rest/v1/status) != '200' ]; do
    sleep 5
done

OLD_PASS=$(cat /var/lib/sonatype-work/nexus3/admin.password)
NEW_PASS=$(cat /proc/sys/kernel/random/uuid)

curl -s -X 'PUT'\
 'http://127.0.0.1:8081/service/rest/v1/security/users/admin/change-password'\
 -u admin:${OLD_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: text/plain'\
 -d ${NEW_PASS}

echo ${NEW_PASS} > /var/lib/sonatype-work/nexus3/admin.password.new

curl -s -X 'PUT' \
 'http://127.0.0.1:8081/service/rest/v1/security/anonymous'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "enabled": true,
  "userId": "anonymous",
  "realmName": "NexusAuthorizingRealm"
}'

curl -X 'PUT'\
 'http://127.0.0.1:8081/service/rest/v1/security/realms/active'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '[
  "NexusAuthenticatingRealm",
  "NexusAuthorizingRealm",
  "DockerToken"
]'

curl -s -X 'DELETE'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/maven-public'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/maven-central'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/maven-releases'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/maven-snapshots'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/nuget-group'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/nuget.org-proxy'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/nuget-hosted'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'


curl -X 'POST'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/docker/hosted'\
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
 'http://127.0.0.1:8081/service/rest/v1/repositories/yum/proxy'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "yum-proxy-redhat",
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
 'http://127.0.0.1:8081/service/rest/v1/repositories/yum/proxy'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "yum-proxy-ansible",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true
  },
  "cleanup": null,
  "proxy": {
    "remoteUrl": "https://cdn.redhat.com/content/dist/layered/rhel8/x86_64/ansible/2/os/",
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
 'http://127.0.0.1:8081/service/rest/v1/repositories/yum/proxy'\
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
 'http://127.0.0.1:8081/service/rest/v1/repositories/yum/proxy'\
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
    "remoteUrl": "http://mirror.centos.org/centos/8-stream/hyperscale/x86_64/packages-main/",
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
 'http://127.0.0.1:8081/service/rest/v1/repositories/yum/proxy'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "yum-proxy-facebook",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true
  },
  "cleanup": null,
  "proxy": {
    "remoteUrl": "http://mirror.centos.org/centos/8-stream/hyperscale/x86_64/packages-facebook/",
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

touch /var/lib/sonatype-work/nexus3/.lock
