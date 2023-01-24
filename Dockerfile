FROM cimg/openjdk:17.0-node
USER root
RUN mkdir /usr/local/tmp && cd /usr/local/tmp && git clone https://github.com/bats-core/bats-core.git && bats-core/install.sh /usr/local
RUN mkdir -p /usr/local/tmp && cd /usr/local/tmp
