setup() {
    # source script under test
    source ./src/scripts/package-install.sh
    # initialise with defaults from src/commands/package-install.yml
    export PARAM_INSTALL_RELEASE_CANDIDATE=0
    export PARAM_QUERY_LATEST_BUILD=1
    export PARAM_PACKAGE_VERSION="PACKAGE_VERSION"
    export PARAM_PACKAGE_ID="PACKAGE_ID"
    export PARAM_INSTALLATION_KEY=INSTALLATION_KEY
    export INSTALLATION_KEY="abc"
    export PARAM_DEVHUB_USERNAME=
}

teardown() {
    rm -f package_version_install_result.json
}

@test "Install Package > Valid package version with installation key > installs package" {
    # ARRANGE
    export PARAM_QUERY_LATEST_BUILD=0
    export PARAM_TARGET_ORG='info@lietzau-consulting.de'
    # this package version was created with the default installation key ("abc")
    export PACKAGE_VERSION='04t08000000gZOGAA2'

    # ACT
    run main

    # ASSERT
    echo "Output: $output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Installing 04t08000000gZOGAA2 on info@lietzau-consulting.de"* ]]
    [[ $output == *"Successfully installed package [04t08000000gZOGAA2]"* ]]
    [[ $output != *"sf project deploy start"* ]]
}

@test "Install Package > Valid package version without installation key > installs package" {
    # ARRANGE
    export PARAM_QUERY_LATEST_BUILD=0
    export PARAM_TARGET_ORG='info@lietzau-consulting.de'
    export INSTALLATION_KEY=
    # this package version was created with the default installation key ("abc")    
    export PACKAGE_VERSION='04t08000000gZPiAAM'

    # ACT
    run main

    # ASSERT
    echo "Output: $output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Installing 04t08000000gZPiAAM on info@lietzau-consulting.de"* ]]
    [[ $output == *"Successfully installed package [04t08000000gZPiAAM]"* ]]
}

@test "Install Package > Query latest release candidate > Installs RC package version" {
    # ARRANGE
    export PARAM_INSTALL_RELEASE_CANDIDATE=1
    export PACKAGE_ID='0Ho08000000CaRqCAK'
    export PARAM_QUERY_LATEST_BUILD=1
    export PARAM_TARGET_ORG='info@lietzau-consulting.de'
    export PARAM_DEVHUB_USERNAME='info@lietzau-consulting.de'
    export INSTALLATION_KEY='abc'
    expectedPackageId=$( sf data query --use-tooling-api --query "SELECT SubscriberPackageVersionId FROM Package2Version WHERE Package2Id = '0Ho08000000CaRqCAK' AND ValidationSkipped = false ORDER BY CreatedDate DESC LIMIT 1" --target-org "${PARAM_DEVHUB_USERNAME}" --result-format csv | sed "1 d" )

    # ACT
    run main

    # ASSERT
    echo "Output: $output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Installing $expectedPackageId on info@lietzau-consulting.de"* ]]
    [[ $output == *"Successfully installed package [$expectedPackageId]"* ]]
}

@test "Set post install source path > deploys source after install" {
    # Arrange
    export PARAM_QUERY_LATEST_BUILD=0
    export PARAM_TARGET_ORG='info@lietzau-consulting.de'
    export PARAM_POST_INSTALL_SOURCE_PATH=src/deploy/main
    export PARAM_PROJECT_PATH=salesforce/demo-package
    # this package version was created with the default installation key ("abc")
    export PACKAGE_VERSION='04t08000000gZOGAA2'

    # Act
    run main

    # Assert
    echo "Output: $output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"sf project deploy start"* ]]
}

@test "Set post install source path > deploys source after install" {
    # Arrange
    export PARAM_QUERY_LATEST_BUILD=0
    export PARAM_TARGET_ORG='info@lietzau-consulting.de'
    export PARAM_POST_INSTALL_SOURCE_PATH='src/deploy/main src/deploy/special'
    export PARAM_PROJECT_PATH=salesforce/demo-package
    # this package version was created with the default installation key ("abc")
    export PACKAGE_VERSION='04t08000000gZOGAA2'

    # Act
    run main

    # Assert
    echo "Output: $output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"sf project deploy start --source-dir src/deploy/main src/deploy/special"* ]]
}
