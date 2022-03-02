setup() {
    # source script under test
    source ./src/scripts/package-get-installed.sh

    # mock environment variables
    export PARAM_PACKAGE_ID="PACKAGE_ID"
    export PARAM_PACKAGE_VERSION_EXPORT="INSTALLED_PACKAGE_VERSION_ID"
    export PARAM_TARGET_ORG="info@lietzau-consulting.de"
    export PARAM_DEVHUB_USERNAME="info@lietzau-consulting.de"
    export PACKAGE_ID="0Ho08000000CaRqCAK"

    # mock the CircleCI BASH_ENV and create an empty file there
    mkdir -p ~/circleci_bash_env
    export BASH_ENV=~/circleci_bash_env/mocked_bash_env.txt
    >"$BASH_ENV"
}

teardown() {
    rm -f $BASH_ENV
}

@test "Mocked package version id > Package exists on target org > Version Id exported" {
    # ACT
    # mock force:data:soql:query result
    function get_installed_package_version_id() {
        echo "04t08000000gZPYAA2"
    }
    export -f get_installed_package_version_id
    run main

    # ASSERT
    exportedBashEnv=$(< $BASH_ENV)
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    echo "BASH_ENV: $exportedBashEnv"
    [ "$status" -eq 0 ]
    [ -f $BASH_ENV ]
    # found subscriber package id
    [[ "$output" == *"03308000000g3fVAAQ"* ]]
    # found mocked subscriber package version id
    [[ "$output" == *"Exporting installed package version 04t08000000gZPYAA2 to INSTALLED_PACKAGE_VERSION_ID"* ]]
    [[ $exportedBashEnv == 'export INSTALLED_PACKAGE_VERSION_ID=04t08000000gZPYAA2' ]]
}

@test "Mocked invalid subscriber package id > Package not installed on target org > Nothing exported" {
    # ACT
    # mock force:data:soql:query result
    function get_subscriber_package_id() {
        echo "03308000000xxxxAAA"
    }
    export -f get_subscriber_package_id
    run main

    # ASSERT
    exportedBashEnv=$(< $BASH_ENV)
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    echo "BASH_ENV: $exportedBashEnv"
    [ "$status" -eq 0 ]
    # found subscriber package id
    [[ "$output" == *"03308000000xxxxAAA"* ]]
    [[ "$output" == *"No installed package version found on org. Nothing exported."* ]]
    [ -f $BASH_ENV ]
    [[ -z $exportedBashEnv ]]
}

@test "Mocked valid subscriber package id > Package installed on target org > Package version id exported" {
    # ACT
    # mock force:data:soql:query result
    function get_subscriber_package_id() {
        echo "03308000000g3fVAAQ"
    }
    export -f get_subscriber_package_id
    run main

    # ASSERT
    exportedBashEnv=$(< $BASH_ENV)
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    echo "BASH_ENV: $exportedBashEnv"
    [ "$status" -eq 0 ]
    # found subscriber package id
    [[ "$output" == *"Found subscriber package id for 0Ho08000000CaRqCAK: 03308000000g3fVAAQ"* ]]
    [[ $exportedBashEnv == 'export INSTALLED_PACKAGE_VERSION_ID=04t'* ]]
}

@test "Mocked subscriber id and version id > Custom environment variable > Package version id exported" {
    # ARRANGE
    export PARAM_PACKAGE_VERSION_EXPORT="MY_INSTALLED_ID_FOR_ROLLBACK"

    # ACT
    # mock force:package:version:create with a successful package create request
    function get_subscriber_package_id() {
        echo "03308000000g3fVAAQ"
    }
    export -f get_subscriber_package_id
    function get_installed_package_version_id() {
        echo "04t08000000gZPYAA2"
    }
    export -f get_installed_package_version_id
    run main

    # ASSERT
    exportedBashEnv=$(< $BASH_ENV)
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    echo "BASH_ENV: $exportedBashEnv"
    [ "$status" -eq 0 ]
    # found subscriber package id
    [[ "$output" == *"03308000000g3fVAAQ"* ]]
    [[ "$output" == *"Exporting installed package version 04t08000000gZPYAA2 to MY_INSTALLED_ID_FOR_ROLLBACK"* ]]
    [[ $exportedBashEnv == 'export MY_INSTALLED_ID_FOR_ROLLBACK=04t08000000gZPYAA2' ]]
}
