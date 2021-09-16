#ARG registry
#ARG repository
#ARG tag
#ARG release
#
#FROM ${registry}/${repository}:${tag}-${release}
#
#COPY rootfs/ /
#
#RUN dnf -yq install erlang rabbitmq-server\
# && systemctl enable rabbitmq-config.service rabbitmq-server.service\
# && dnf -yq clean all\
# && rm -rf /var/cache/* /var/log/dnf* /var/log/hawkey* /var/log/rhsm/
#
#ENV RABBITMQ_USR=rabbit-user\
#    RABBITMQ_PASS=rabbit-pass
#
#EXPOSE 5672/tcp
#EXPOSE 15672/tcp
