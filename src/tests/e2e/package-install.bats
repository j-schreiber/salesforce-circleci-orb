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
    export PACKAGE_ID='0Ho08000000CaRqCAK'
    export PARAM_QUERY_LATEST_BUILD=1
    export PARAM_TARGET_ORG='info@lietzau-consulting.de'
    export PARAM_DEVHUB_USERNAME='info@lietzau-consulting.de'
    export INSTALLATION_KEY='abc'
    expectedPackageId=$( sfdx force:data:soql:query -t -q "SELECT SubscriberPackageVersionId FROM Package2Version WHERE Package2Id = '0Ho08000000CaRqCAK' AND ValidationSkipped = false ORDER BY CreatedDate DESC LIMIT 1" -u "${PARAM_DEVHUB_USERNAME}" -r csv | sed "1 d" )

    # ACT
    run main

    # ASSERT
    echo "Output: $output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Installing $expectedPackageId on info@lietzau-consulting.de"* ]]
    [[ $output == *"Successfully installed package [$expectedPackageId]"* ]]
}
