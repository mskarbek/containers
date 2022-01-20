#!/usr/bin/env bash

rabbitmq-plugins enable rabbitmq_managment
rabbitmq-plugins enable rabbitmq_auth_backend_ldap
rabbitmqctl add_user ${RABBITMQ_USER} ${RABBITMQ_PASS}
rabbitmqctl set_permissions -p "/" ${RABBITMQ_USER} ".*" ".*" ".*"
rabbitmqctl set_user_tags ${RABBITMQ_USER} administrator
rabbitmqctl delete_user guest
