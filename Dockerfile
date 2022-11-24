FROM cimg/base:stable
USER root
RUN mkdir /usr/local/tmp && cd /usr/local/tmp && git clone https://github.com/bats-core/bats-core.git && bats-core/install.sh /usr/local
RUN mkdir -p /usr/local/tmp && cd /usr/local/tmp
RUN wget https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.xz
RUN mkdir -p /usr/local/sfdx
RUN tar xJf sfdx-linux-x64.tar.xz -C /usr/local/sfdx --strip-components 1
RUN sudo ln -sf /usr/local/sfdx/bin/sfdx /bin/sfdx
