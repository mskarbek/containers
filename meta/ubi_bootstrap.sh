#!/usr/bin/env bash

rm -rf /etc/rhsm-host
rm -rf /etc/pki/entitlement-host
subscription-manager register --auto-attach --release=8.4 --username=<user> --password=<password>

pushd /etc/pki/entitlement
    PEM=$(ls -1 *-key.pem|sed 's/-key.pem//')
popd

PASS=$(cat /proc/sys/kernel/random/uuid)

openssl pkcs12\
 -export\
 -in /etc/pki/entitlement/${PEM}.pem\
 -inkey /etc/pki/entitlement/${PEM}-key.pem\
 -name certificate_and_key\
 -out /root/certificate_and_key.p12\
 -passout pass:${PASS}

keytool\
 -importkeystore\
 -srckeystore /root/certificate_and_key.p12\
 -srcstoretype PKCS12\
 -srcstorepass ${PASS}\
 -deststorepass ${PASS}\
 -destkeystore /root/keystore.p12\
 -deststoretype PKCS12

echo ${PASS} > /root/keystore.pass
