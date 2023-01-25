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

@test "Has package version installed > Installed version Id exported" {
    # Arrange
    function query_subscriber_package_id() {
        cat src/tests/data/existing-subscriber-package-id.json
    }
    export -f query_subscriber_package_id
    function query_installed_package_version_id() {
        cat src/tests/data/has-package-version-installed.json
    }
    export -f query_installed_package_version_id

    # Act
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
    [[ "$output" == *"0330X0000000000AAA"* ]]
    # found mocked subscriber package version id
    [[ "$output" == *"Exporting installed package version 04t9Y0000000000AAA to INSTALLED_PACKAGE_VERSION_ID"* ]]
    [[ $exportedBashEnv == 'export INSTALLED_PACKAGE_VERSION_ID=04t9Y0000000000AAA' ]]
}

@test "Unknown package with no subscriber package > Nothing exported" {
    # Arrange
    function query_subscriber_package_id() {
        cat src/tests/data/empty-query-result.json
    }
    export -f query_subscriber_package_id
    function query_installed_package_version_id() {
        cat src/tests/data/empty-query-result.json
    }
    export -f query_installed_package_version_id

    # Act
    run main

    # ASSERT
    exportedBashEnv=$(< $BASH_ENV)
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    echo "BASH_ENV: $exportedBashEnv"
    [ "$status" -eq 0 ]
    [[ "$output" == *"No Subscriber Package Id found. Nothing exported."* ]]
    [ -f $BASH_ENV ]
    [[ -z $exportedBashEnv ]]
}

@test "Known package but no version installed on org > Nothing exported" {
    # Arrange
    function query_subscriber_package_id() {
        cat src/tests/data/existing-subscriber-package-id.json
    }
    export -f query_subscriber_package_id
    function query_installed_package_version_id() {
        cat src/tests/data/empty-query-result.json
    }
    export -f query_installed_package_version_id

    # Act
    run main

    # ASSERT
    exportedBashEnv=$(< $BASH_ENV)
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    echo "BASH_ENV: $exportedBashEnv"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Subscriber Package Id for 0Ho08000000CaRqCAK: 0330X0000000000AAA"* ]]
    [[ "$output" == *"No installed package version found on info@lietzau-consulting.de. Nothing exported."* ]]
    [ -f $BASH_ENV ]
    [[ -z $exportedBashEnv ]]
}

@test "Custom variable name for package version export > Exported to custom variable" {
    # Arrange
    function query_subscriber_package_id() {
        cat src/tests/data/existing-subscriber-package-id.json
    }
    export -f query_subscriber_package_id
    function query_installed_package_version_id() {
        cat src/tests/data/has-package-version-installed.json
    }
    export -f query_installed_package_version_id
    export PARAM_PACKAGE_VERSION_EXPORT=MY_INSTALLED_ID_FOR_ROLLBACK

    # Act
    run main

    # Assert
    exportedBashEnv=$(< $BASH_ENV)
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    echo "BASH_ENV: $exportedBashEnv"
    [ "$status" -eq 0 ]
    # found subscriber package id
    [[ "$output" == *"Exporting installed package version 04t9Y0000000000AAA to MY_INSTALLED_ID_FOR_ROLLBACK"* ]]
    [[ $exportedBashEnv == 'export MY_INSTALLED_ID_FOR_ROLLBACK=04t9Y0000000000AAA' ]]
}
