#!/usr/bin/env bash

if [ -f /var/lib/sonatype-work/nexus3/.lock ]; then
    exit 0
fi

while [ $(curl -s -o /dev/null -w '%{response_code}' -I http://127.0.0.1:8081/service/rest/v1/status) != '200' ]; do
    sleep 5
done

OLD_PASS=$(cat /var/lib/sonatype-work/nexus3/admin.password)
NEW_PASS=$(cat /proc/sys/kernel/random/uuid)

curl -X 'PUT'\
 'http://127.0.0.1:8081/service/rest/v1/security/users/admin/change-password'\
 -u admin:${OLD_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: text/plain'\
 -d ${NEW_PASS}

echo ${NEW_PASS} > /var/lib/sonatype-work/nexus3/admin.password.new

curl -X 'PUT' \
 'http://127.0.0.1:8081/service/rest/v1/security/anonymous'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'\
 -H 'Content-Type: application/json'\
 -d '{
  "enabled": true,
  "userId": "anonymous",
  "realmName": "NexusAuthorizingRealm"
}'

curl -X 'DELETE'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/maven-public'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -X 'DELETE'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/maven-central'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -X 'DELETE'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/maven-releases'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -X 'DELETE'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/maven-snapshots'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -X 'DELETE'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/nuget-group'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -X 'DELETE'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/nuget.org-proxy'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

curl -X 'DELETE'\
 'http://127.0.0.1:8081/service/rest/v1/repositories/nuget-hosted'\
 -u admin:${NEW_PASS}\
 -H 'accept: application/json'

touch /var/lib/sonatype-work/nexus3/.lock
