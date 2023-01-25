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

    # mock force:package:beta:install
    function install_package_with_params() {
        echo "sfdx force:package:install $@"
    }
}

@test "Default command initialisation > Queries and installs latest package" {
    # ARRANGE
    export PARAM_TARGET_ORG='info@lietzau-consulting.de'
    export PARAM_DEVHUB_USERNAME='info@lietzau-consulting.de'
    export PACKAGE_ID='0Ho08000000CaRqCAK'

    function sfdx_force_data_soql_query() {
        cat src/tests/data/latest-package-build.json
    }

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"--installationkey"* ]]
    [[ $output == *"Installing 04t9Y0000000000AAA on info@lietzau-consulting.de"* ]]
    [[ $output == *"sfdx force:package:install --package 04t9Y0000000000AAA --targetusername info@lietzau-consulting.de --noprompt --wait 10 --publishwait 10 --installationkey abc" ]]
    [[ $output != *"sfdx force:source:deploy"* ]]
}

@test "Set package version explicitly > Installs input package version" {
    # ARRANGE
    export PARAM_TARGET_ORG='info@lietzau-consulting.de'
    export PACKAGE_VERSION='04t08000000gZOGAA3'
    export PARAM_QUERY_LATEST_BUILD=0

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Installing 04t08000000gZOGAA3 on info@lietzau-consulting.de"* ]]
}

@test "Set package version in custom variable > Installs input package version" {
    # ARRANGE
    export PARAM_TARGET_ORG='info@lietzau-consulting.de'
    export PARAM_PACKAGE_VERSION=MY_TEST_PACKAGE_VERSION
    export MY_TEST_PACKAGE_VERSION='04t08000000gZOGAA4'
    export PARAM_QUERY_LATEST_BUILD=0

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Installing 04t08000000gZOGAA4 on info@lietzau-consulting.de"* ]]
}

@test "Set package in custom variable > Query and install latest package version" {
    # ARRANGE
    export PARAM_TARGET_ORG='business@lietzau-consulting.de'
    export PARAM_DEVHUB_USERNAME='info@lietzau-consulting.de'
    export PARAM_PACKAGE_ID=MY_TEST_PACKAGE_ID
    export MY_TEST_PACKAGE_ID='0Ho08000000CaRqXXX'

    function sfdx_force_data_soql_query() {
        cat src/tests/data/latest-package-build.json
    }

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Finding latest package version for 0Ho08000000CaRqXXX"* ]]
    [[ $output == *"Installing 04t9Y0000000000AAA on business@lietzau-consulting.de"* ]]
}

@test "Set to install set release candidate > Query and install latest release candidate" {
    # ARRANGE
    export PARAM_TARGET_ORG='business@lietzau-consulting.de'
    export PARAM_DEVHUB_USERNAME='info@lietzau-consulting.de'
    export PACKAGE_ID='0Ho08000000CaRqXXX'
    export PARAM_INSTALL_RELEASE_CANDIDATE=1

    function sfdx_force_data_soql_query() {
        cat src/tests/data/latest-package-build.json
    }

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Finding latest release candidate for 0Ho08000000CaRqXXX"* ]]
    [[ $output == *"Installing 04t9Y0000000000AAA on business@lietzau-consulting.de"* ]]
}

@test "Install with empty installation key > install request without installation key" {
    # ARRANGE
    export PARAM_TARGET_ORG='business@lietzau-consulting.de'
    export PARAM_DEVHUB_USERNAME='info@lietzau-consulting.de'
    export PACKAGE_VERSION=04t08000000gZOGAA3
    export INSTALLATION_KEY=
    export PARAM_QUERY_LATEST_BUILD=0

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Installing 04t08000000gZOGAA3 on business@lietzau-consulting.de"* ]]
    [[ $output == *"sfdx force:package:install --package 04t08000000gZOGAA3 --targetusername business@lietzau-consulting.de --noprompt --wait 10 --publishwait 10" ]]
    [[ $output != *"--installationkey"* ]]
}

@test "Specify post install source > source deployed after package install" {
    # ARRANGE
    export PARAM_TARGET_ORG='business@lietzau-consulting.de'
    export PARAM_DEVHUB_USERNAME='info@lietzau-consulting.de'
    export PACKAGE_VERSION=04t08000000gZOGAA3
    export INSTALLATION_KEY=
    export PARAM_QUERY_LATEST_BUILD=0
    export PARAM_POST_INSTALL_SOURCE_PATH=src/deploy
    
    function sfdx_force_source_deploy() {
        echo "sfdx force:source:deploy $@"
    }

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Installing 04t08000000gZOGAA3 on business@lietzau-consulting.de"* ]]
    [[ $output == *"sfdx force:source:deploy --sourcepath src/deploy --targetusername business@lietzau-consulting.de --wait 10 --testlevel RunLocalTests" ]]
}

@test "Query latest build does not find package > exits with error" {
    # ARRANGE
    export PARAM_TARGET_ORG='business@lietzau-consulting.de'
    export PARAM_DEVHUB_USERNAME='info@lietzau-consulting.de'
    export PACKAGE_ID='0Ho08000000CaRqXXX'
    export PARAM_INSTALL_RELEASE_CANDIDATE=1

    function sfdx_force_data_soql_query() {
        cat src/tests/data/empty-query-result.json
    }

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 20 ]
    [[ $output == *"No valid package version retrieved. Exiting ..."* ]]
    [[ $output != *"Installing"* ]]
    [[ $output != *"sfdx force:package:install"* ]]
}

@test "Empty package version with rollback > exits without error" {
    # ARRANGE
    export PARAM_TARGET_ORG='info@lietzau-consulting.de'
    export PACKAGE_VERSION=
    export PARAM_QUERY_LATEST_BUILD=0
    export PARAM_IS_ROLLBACK=1

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Running in rollback mode but found no package version. Skipping ..."* ]]
    [[ $output != *"sfdx force:package:install"* ]]
}

@test "Verify Params > No devhub org set for latest package > exits with error" {
    # ARRANGE
    export PARAM_DEVHUB_USERNAME=
    export PARAM_TARGET_ORG='info@lietzau-consulting.de'
    export PACKAGE_ID='0Ho08000000CaRqCAK'

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 13 ]
}

@test "Verify Params > Target org not initialised" {
    # ARRANGE
    export PARAM_TARGET_ORG=

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 10 ]
}

@test "Verify Params > Target org set with empty value" {
    # ARRANGE
    export PARAM_TARGET_ORG=

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 10 ]
}

@test "Verify Params > Package version and package are empty" {
    # ARRANGE
    export PARAM_TARGET_ORG='info@lietzau-consulting.de'
    export PACKAGE_VERSION=
    export PACKAGE_ID=

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 11 ]
}

@test "Verify Params > Set to use package version but variable is empty" {
    # ARRANGE
    export PARAM_TARGET_ORG='info@lietzau-consulting.de'
    export PACKAGE_ID='0Ho08000000CaRqCAK'
    export PACKAGE_VERSION=
    export PARAM_QUERY_LATEST_BUILD=0

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 14 ]
}
