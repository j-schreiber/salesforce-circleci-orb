#! /bin/bash
set -e

Install() {
    if command -v sfdx &> /dev/null; then
        exit 0
    fi
    mkdir -p ~/tmp && cd ~/tmp
    wget https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.xz
    mkdir -p ~/sfdx
    tar xJf sfdx-linux-x64.tar.xz -C ~/sfdx --strip-components 1
    sudo ln -sf ~/sfdx/bin/sfdx /bin/sfdx
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    Install
fi
