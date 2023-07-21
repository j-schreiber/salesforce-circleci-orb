setup() {
    # source script under test
    source ./src/scripts/install-cli.sh
    source ./src/scripts/install-tmh-cli-plugin.sh
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
    sudo rm -rf ~/.local/share/sf ~/.config/sf ~/.cache/sf
    sudo rm -rf ~/Library/Caches/sf
    sudo rm -f /bin/sfdx
    sudo rm -f /bin/sf
    sudo rm -f /usr/bin/sfdx
    sudo rm -f /usr/bin/sf
    # diagnosis results from sf doctor --json
    rm -f *-diagnosis.json

    if [[ "${#BATS_TEST_NAMES[@]}" -eq "$BATS_TEST_NUMBER" ]]; then
        # install cli for following tests
        run install
    fi
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
    [[ $output == *"Create symlink for SFDX alias"* ]]
    [[ $output == *"Create symlink for SF CLI"* ]]
}

@test "Version in default parameter > installs explicit version" {
    # Arrange
    export SALESFORCE_CLI_VERSION="2.0.2-3bd4327"

    # Act
    run install

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Extracted CLI version from SALESFORCE_CLI_VERSION: 2.0.2 on 3bd4327"* ]]
    [[ $output == *"Explicit version requested. Installing: 2.0.2"* ]]
    [[ $output == *"Create symlink for SFDX alias"* ]]
    [[ $output == *"Create symlink for SF CLI"* ]]
}

@test "Version in custom parameter > installs explicit version" {
    # Arrange
    export PARAM_REQUESTED_CLI_VERSION=MY_CLI_VERSION
    export MY_CLI_VERSION="2.0.2-3bd4327"

    # Act
    run install

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Extracted CLI version from MY_CLI_VERSION: 2.0.2 on 3bd4327"* ]]
    [[ $output == *"Explicit version requested. Installing: 2.0.2"* ]]
    [[ $output == *"Create symlink for SFDX alias"* ]]
    [[ $output == *"Create symlink for SF CLI"* ]]
}

@test "Incomplete version in parameter without SHA > descriptive error message" {
    # Arrange
    export SALESFORCE_CLI_VERSION=2.0.2

    # Act
    run install

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 11 ]
    [[ $output == *"Could not extract a valid commit SHA from SALESFORCE_CLI_VERSION. Input was: 2.0.2"* ]]
    [[ $output == *"Reference the manifest to find the correct SHA for the requested version: https://developer.salesforce.com/media/salesforce-cli/sf/versions/sf-linux-x64-tar-xz.json"* ]]
}

# Not able to get an old version, which would fail -> not testable anymore
# @test "Installed CLI version is incompatible with TMH plugin > exits with error message" {
#     # Arrange
#     export SALESFORCE_CLI_VERSION="7.176.1-458b658"

#     # Act
#     run install
#     run install_and_verify_tmh_plugin

#     # Assert
#     echo "Actual output"
#     echo "$output"
#     echo "Actual status: $status"
#     [ "$status" -eq 13 ]
# }

@test "Installed CLI version is compatible with TMH plugin > finishes plugin install" {
    # Arrange
    export SALESFORCE_CLI_VERSION="2.0.2-3bd4327"

    # Act
    run install
    run install_and_verify_tmh_plugin

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
}
