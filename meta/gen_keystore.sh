#!/usr/bin/env bash
set -eu

if [ -f ./keystore.p12 ]
then
    exit 0
fi

PEMS=$(grep -e 'entitlement.*-key.pem' /etc/yum.repos.d/redhat.repo|sort|uniq|awk -F/ '{print $5}'|sed 's/-key\.pem//')

PASS=$(cat /proc/sys/kernel/random/uuid)
echo ${PASS} > ./keystore.pass

for PEM in ${PEMS}
do
    if [ -f /etc/pki/entitlement-host/${PEM}.pem ]
    then
        ENTITLEMENT_PATH=/etc/pki/entitlement-host
    else
        ENTITLEMENT_PATH=/etc/pki/entitlement
    fi

    openssl pkcs12\
     -export\
     -in ${ENTITLEMENT_PATH}/${PEM}.pem\
     -inkey ${ENTITLEMENT_PATH}/${PEM}-key.pem\
     -name ${PEM}\
     -out ./${PEM}.p12\
     -legacy\
     -passout pass:${PASS}

    keytool\
     -importkeystore\
     -srckeystore ./${PEM}.p12\
     -srcstoretype PKCS12\
     -srcstorepass ${PASS}\
     -deststorepass ${PASS}\
     -destkeystore ./keystore.p12\
     -deststoretype PKCS12

    rm -vf ./${PEM}.p12
done
