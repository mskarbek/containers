#!/usr/bin/env bash

rm -rf /etc/rhsm-host
rm -rf /etc/pki/entitlement-host
subscription-manager register --auto-attach --release=8.4 --username=<user> --password=<password>
