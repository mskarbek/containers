#!/usr/bin/env bash

if [ -z ${NEXUS_PASSWORD} ]; then
    echo "NEXUS_PASSWORD variable empty"
    exit 1
fi

while [ $(curl -s -o /dev/null -w '%{response_code}' -I "http://127.0.0.1:8081/service/rest/v1/status") != '200' ]; do
    echo "Waiting for Nexus"
    sleep 5
done

echo "Setting up admin password"
curl -s -X 'PUT'\
 "http://127.0.0.1:8081/service/rest/v1/security/users/admin/change-password"\
 -u admin:$(cat /var/lib/sonatype-work/nexus3/admin.password)\
 -H 'accept: application/json'\
 -H 'Content-Type: text/plain'\
 -d ${NEXUS_PASSWORD}
