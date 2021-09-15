#!/usr/bin/env bash

if [[ -f /opt/kafka/config/.lock ]]; then
    exit 0
fi

IP=$(cat /proc/net/fib_trie|awk '/32 host/ {print ip} {ip=$2}'|sort|uniq|grep -v 127)
sed -i "s/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/${IP}:9092/" /opt/kafka/config/server.properties
touch /opt/kafka/config/.lock
