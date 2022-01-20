#!/usr/bin/env bash

if [ -z ${RABBITMQ_USER} ] || [ -z ${RABBITMQ_PASS} ]; then
    echo "ERROR: Missing RABBITMQ_USER or RABBITMQ_PASS"
    exit 1
fi

rabbitmq-plugins enable rabbitmq_management
rabbitmq-plugins enable rabbitmq_auth_backend_ldap
rabbitmq-plugins enable rabbitmq_prometheus
rabbitmqctl add_user ${RABBITMQ_USER} ${RABBITMQ_PASS}
rabbitmqctl set_permissions -p "/" ${RABBITMQ_USER} ".*" ".*" ".*"
rabbitmqctl set_user_tags ${RABBITMQ_USER} administrator
rabbitmqctl delete_user guest
