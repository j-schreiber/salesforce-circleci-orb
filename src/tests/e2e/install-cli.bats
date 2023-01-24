setup() {
    # source script under test
    source ./src/scripts/install-cli.sh
    export PARAM_REQUESTED_CLI_VERSION=SFDX_CLI_VERSION
}

teardown() {
    # https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_uninstall.htm
    sudo rm -rf /usr/local/sfdx
    sudo rm -rf /usr/local/lib/sfdx
    sudo rm -rf /usr/local/bin/sfdx
    sudo rm -rf ~/.local/share/sfdx ~/.config/sfdx ~/.cache/sfdx
    sudo rm -rf ~/Library/Caches/sfdx
    sudo rm -rf /usr/local/sf
    sudo rm -rf /usr/local/bin/sf
    sudo rm -f /bin/sfdx
    sudo rm -f /usr/bin/sfdx
}

@test "No requested version set > installs latest version" {
    # Act
    run install

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"No explicit version requested. Installing latest version."* ]]
}

@test "Explicit version requested in default parameter > installs explicit version" {
    # Arrange
    export SFDX_CLI_VERSION="7.176.1-458b658"

    # Act
    run install

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Extracted CLI version from SFDX_CLI_VERSION: 7.176.1 on 458b658"* ]]
    [[ $output == *"Explicit version requested. Installing: 7.176.1"* ]]
}

@test "Explicit version requested without sha > descriptive error message" {
    # Arrange
    export SFDX_CLI_VERSION=7.185.0

    # Act
    run install

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 11 ]
    [[ $output == *"Could not extract a valid commit SHA from SFDX_CLI_VERSION. Input was: 7.185.0"* ]]
    [[ $output == *"Reference the manifest to find the correct SHA for the requested version: https://developer.salesforce.com/media/salesforce-cli/sfdx/versions/sfdx-linux-x64-tar-xz.json"* ]]
}
