#! /bin/bash
set -e

install_and_verify_tmh_plugin() {
    mkdir -p "$HOME"/.config/sf
    mkdir -p tmp
    echo '["@tmh-bis-salesforce/tmh-bis-salesforce-cli-plugin"]' > "$HOME"/.config/sf/unsignedPluginAllowList.json
    sf plugins install @tmh-bis-salesforce/tmh-bis-salesforce-cli-plugin
    sf doctor --json > tmp/doctor-result.json
    cliVersionSupported=$(jq -r '.result.pluginSpecificData."@tmh-bis-salesforce/tmh-bis-salesforce-cli-plugin"[0].isSupportedCliVersion' tmp/doctor-result.json)
    pluginErrorMessage=$(jq -r '.result.pluginSpecificData."@tmh-bis-salesforce/tmh-bis-salesforce-cli-plugin"[0].errorMessage' tmp/doctor-result.json)
    if [ "$cliVersionSupported" == "false" ]; then
        echo "Incompatible CLI version: $pluginErrorMessage"
        exit 13
    elif [ "$cliVersionSupported" == "null" ]; then
        echo 'TMH Salesforce CLI plugin not installed.'
        exit 14
    fi
    echo 'TMH Salesforce CLI plugin installed and ready to use.'
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    install_and_verify_tmh_plugin
fi
