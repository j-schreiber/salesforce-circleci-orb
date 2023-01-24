#! /bin/bash
set -e

verify_params() {
    if [ -n "${!PARAM_REQUESTED_CLI_VERSION}" ]; then
        IFS='-' read -ra CLI_VERSION_PARTS <<< "${!PARAM_REQUESTED_CLI_VERSION}"
        CLI_VERSION=${CLI_VERSION_PARTS[0]}
        COMMIT_SHA=${CLI_VERSION_PARTS[1]}
        if [ -z "$CLI_VERSION" ]; then
            echo "Could not extract a valid CLI version from ${PARAM_REQUESTED_CLI_VERSION}. Input was: ${!PARAM_REQUESTED_CLI_VERSION}"
            echo_error_instructions
            exit 10
        fi
        if [ -z "$COMMIT_SHA" ]; then
            echo "Could not extract a valid commit SHA from ${PARAM_REQUESTED_CLI_VERSION}. Input was: ${!PARAM_REQUESTED_CLI_VERSION}"
            echo_error_instructions
            exit 11
        fi
        echo "Extracted CLI version from ${PARAM_REQUESTED_CLI_VERSION}: $CLI_VERSION on $COMMIT_SHA"
    fi
}

echo_error_instructions() {
    echo "Reference the manifest to find the correct SHA for the requested version: https://developer.salesforce.com/media/salesforce-cli/sfdx/versions/sfdx-linux-x64-tar-xz.json"
    echo "Provide the CLI version together with the correct SHA in the format: x.y.z-SHA (e.g. 7.176.1-458b658)"
}

install() {
    verify_params
    # if command -v sfdx &> /dev/null; then
    #    exit 0
    # fi
    mkdir -p ~/tmp && cd ~/tmp
    if [ -n "${!PARAM_REQUESTED_CLI_VERSION}" ]; then
        download_explicit_version
    else
        download_latest_version
    fi
    symlink_version
}

download_explicit_version() {
    echo "Explicit version requested. Installing: $CLI_VERSION"
    wget "https://developer.salesforce.com/media/salesforce-cli/sfdx/versions/$CLI_VERSION/$COMMIT_SHA/sfdx-v$CLI_VERSION-$COMMIT_SHA-linux-x64.tar.xz"
    mkdir -p ~/sfdx
    tar xJf "sfdx-v$CLI_VERSION-$COMMIT_SHA-linux-x64.tar.xz" -C ~/sfdx --strip-components 1
}

download_latest_version() {
    echo "No explicit version requested. Installing latest version."
    wget https://developer.salesforce.com/media/salesforce-cli/sfdx/channels/stable/sfdx-linux-x64.tar.xz
    mkdir -p ~/sfdx
    tar xJf sfdx-linux-x64.tar.xz -C ~/sfdx --strip-components 1
}

symlink_version() {
    sudo ln -sf ~/sfdx/bin/sfdx /bin/sfdx
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    install
fi
