#!/usr/bin/env bash

URL_MINIO="http://minio.lab.skarbek.name:9000"
URL_NEXUS="http://repo.lab.skarbek.name:8081"

MINIO_USER="Root-User"
MINIO_PASS="Root-Pass"

while [ $(curl -s -o /dev/null -w '%{response_code}' -I "${URL_NEXUS}/service/rest/v1/status") != '200' ]; do
    sleep 5
done

OLD_PASS=$(cat files/admin.password)
NEW_PASS=$(cat /proc/sys/kernel/random/uuid)
echo ${NEW_PASS} > files/admin.password.new

curl -s -X 'PUT'\
 "${URL_NEXUS}/service/rest/v1/security/users/admin/change-password"\
 -u admin:${OLD_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: text/plain'\
 -d ${NEW_PASS}

curl -s -X 'PUT' \
 "${URL_NEXUS}/service/rest/v1/security/anonymous"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "enabled": true,
  "userId": "anonymous",
  "realmName": "NexusAuthorizingRealm"
}'

curl -X 'PUT'\
 "${URL_NEXUS}/service/rest/v1/security/realms/active"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '[
  "NexusAuthenticatingRealm",
  "NexusAuthorizingRealm",
  "DockerToken"
]'

curl -s -X 'DELETE'\
 "${URL_NEXUS}/service/rest/v1/repositories/maven-public"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 "${URL_NEXUS}/service/rest/v1/repositories/maven-central"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 "${URL_NEXUS}/service/rest/v1/repositories/maven-releases"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 "${URL_NEXUS}/service/rest/v1/repositories/maven-snapshots"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 "${URL_NEXUS}/service/rest/v1/repositories/nuget-group"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 "${URL_NEXUS}/service/rest/v1/repositories/nuget.org-proxy"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 "${URL_NEXUS}/service/rest/v1/repositories/nuget-hosted"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -s -X 'DELETE'\
 "${URL_NEXUS}/service/rest/v1/blobstores/default"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

REDHAT_PEM=$(curl -s -X 'GET'\
  "${URL_NEXUS}/service/rest/v1/security/ssl?host=cdn.redhat.com&port=443"\
  -u admin:${NEW_PASS}\
  -H 'accept: application/json'|jq -r .pem)

curl -vX 'POST' \
  "${URL_NEXUS}/service/rest/v1/security/ssl/truststore"\
  -u admin:${NEW_PASS}\
  -H 'accept: application/json'\
  -H 'Content-Type: text/plain'\
  -d "${REDHAT_PEM}"

curl -X 'POST'\
 "${URL_NEXUS}/service/rest/v1/blobstores/s3"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "minio-oci-hosted-common",
  "softQuota": null,
  "bucketConfiguration": {
    "bucket": {
      "region": "eu-central-1",
      "name": "nexus-oci-hosted-common",
      "prefix": null,
      "expiration": 3
    },
    "bucketSecurity": {
      "accessKeyId": "'${MINIO_USER}'",
      "secretAccessKey": "'${MINIO_PASS}'"
    },
    "advancedBucketConnection": {
      "endpoint": "'${URL_MINIO}'",
      "forcePathStyle": true
    }
  }
}'

curl -X 'POST'\
 "${URL_NEXUS}/service/rest/v1/blobstores/s3"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "minio-yum-hosted-common",
  "softQuota": null,
  "bucketConfiguration": {
    "bucket": {
      "region": "eu-central-1",
      "name": "nexus-yum-hosted-common",
      "prefix": null,
      "expiration": 3
    },
    "bucketSecurity": {
      "accessKeyId": "'${MINIO_USER}'",
      "secretAccessKey": "'${MINIO_PASS}'"
    },
    "advancedBucketConnection": {
      "endpoint": "'${URL_MINIO}'",
      "forcePathStyle": true
    }
  }
}'

curl -X 'POST'\
 "${URL_NEXUS}/service/rest/v1/blobstores/s3"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "minio-yum-proxy-rhel8-8.5",
  "softQuota": null,
  "bucketConfiguration": {
    "bucket": {
      "region": "eu-central-1",
      "name": "nexus-yum-proxy-rhel8-8.5",
      "prefix": null,
      "expiration": 3
    },
    "bucketSecurity": {
      "accessKeyId": "'${MINIO_USER}'",
      "secretAccessKey": "'${MINIO_PASS}'"
    },
    "advancedBucketConnection": {
      "endpoint": "'${URL_MINIO}'",
      "forcePathStyle": true
    }
  }
}'

curl -X 'POST'\
 "${URL_NEXUS}/service/rest/v1/blobstores/s3"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "minio-yum-proxy-rhel8-layered",
  "softQuota": null,
  "bucketConfiguration": {
    "bucket": {
      "region": "eu-central-1",
      "name": "nexus-yum-proxy-rhel8-layered",
      "prefix": null,
      "expiration": 3
    },
    "bucketSecurity": {
      "accessKeyId": "'${MINIO_USER}'",
      "secretAccessKey": "'${MINIO_PASS}'"
    },
    "advancedBucketConnection": {
      "endpoint": "'${URL_MINIO}'",
      "forcePathStyle": true
    }
  }
}'

curl -X 'POST'\
 "${URL_NEXUS}/service/rest/v1/blobstores/s3"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "minio-yum-proxy-hyperscale",
  "softQuota": null,
  "bucketConfiguration": {
    "bucket": {
      "region": "eu-central-1",
      "name": "nexus-yum-proxy-hyperscale",
      "prefix": null,
      "expiration": 3
    },
    "bucketSecurity": {
      "accessKeyId": "'${MINIO_USER}'",
      "secretAccessKey": "'${MINIO_PASS}'"
    },
    "advancedBucketConnection": {
      "endpoint": "'${URL_MINIO}'",
      "forcePathStyle": true
    }
  }
}'

curl -X 'POST'\
 "${URL_NEXUS}/service/rest/v1/blobstores/s3"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "minio-yum-proxy-epel",
  "softQuota": null,
  "bucketConfiguration": {
    "bucket": {
      "region": "eu-central-1",
      "name": "nexus-yum-proxy-epel",
      "prefix": null,
      "expiration": 3
    },
    "bucketSecurity": {
      "accessKeyId": "'${MINIO_USER}'",
      "secretAccessKey": "'${MINIO_PASS}'"
    },
    "advancedBucketConnection": {
      "endpoint": "'${URL_MINIO}'",
      "forcePathStyle": true
    }
  }
}'

curl -X 'POST'\
 "${URL_NEXUS}/service/rest/v1/blobstores/s3"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "minio-yum-proxy-elrepo",
  "softQuota": null,
  "bucketConfiguration": {
    "bucket": {
      "region": "eu-central-1",
      "name": "nexus-yum-proxy-elrepo",
      "prefix": null,
      "expiration": 3
    },
    "bucketSecurity": {
      "accessKeyId": "'${MINIO_USER}'",
      "secretAccessKey": "'${MINIO_PASS}'"
    },
    "advancedBucketConnection": {
      "endpoint": "'${URL_MINIO}'",
      "forcePathStyle": true
    }
  }
}'

curl -X 'POST'\
 "${URL_NEXUS}/service/rest/v1/blobstores/s3"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "minio-yum-proxy-pgdg",
  "softQuota": null,
  "bucketConfiguration": {
    "bucket": {
      "region": "eu-central-1",
      "name": "nexus-yum-proxy-pgdg",
      "prefix": null,
      "expiration": 3
    },
    "bucketSecurity": {
      "accessKeyId": "'${MINIO_USER}'",
      "secretAccessKey": "'${MINIO_PASS}'"
    },
    "advancedBucketConnection": {
      "endpoint": "'${URL_MINIO}'",
      "forcePathStyle": true
    }
  }
}'

curl -X 'POST'\
 "${URL_NEXUS}/service/rest/v1/repositories/docker/hosted"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "oci-hosted-common",
  "online": true,
  "storage": {
    "blobStoreName": "minio-oci-hosted-common",
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
 "${URL_NEXUS}/service/rest/v1/repositories/yum/hosted"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "yum-hosted-common",
  "online": true,
  "storage": {
    "blobStoreName": "minio-yum-hosted-common",
    "strictContentTypeValidation": true,
    "writePolicy": "ALLOW_ONCE"
  },
  "cleanup": null,
  "yum": {
    "repodataDepth": 0,
    "deployPolicy": "STRICT"
  },
  "component": {
    "proprietaryComponents": false
  }
}'

curl -X 'POST'\
 "${URL_NEXUS}/service/rest/v1/repositories/yum/proxy"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "yum-proxy-rhel8-8.5",
  "online": true,
  "storage": {
    "blobStoreName": "minio-yum-proxy-rhel8-8.5",
    "strictContentTypeValidation": true
  },
  "cleanup": null,
  "proxy": {
    "remoteUrl": "https://cdn.redhat.com/content/dist/rhel8/8.5/x86_64/",
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
 "${URL_NEXUS}/service/rest/v1/repositories/yum/proxy"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "yum-proxy-rhel8-layered",
  "online": true,
  "storage": {
    "blobStoreName": "minio-yum-proxy-rhel8-layered",
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
 "${URL_NEXUS}/service/rest/v1/repositories/yum/proxy"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "yum-proxy-hyperscale",
  "online": true,
  "storage": {
    "blobStoreName": "minio-yum-proxy-hyperscale",
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
 "${URL_NEXUS}/service/rest/v1/repositories/yum/proxy"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "yum-proxy-epel",
  "online": true,
  "storage": {
    "blobStoreName": "minio-yum-proxy-epel",
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
 "${URL_NEXUS}/service/rest/v1/repositories/yum/proxy"\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "name": "yum-proxy-elrepo",
  "online": true,
  "storage": {
    "blobStoreName": "minio-yum-proxy-elrepo",
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
