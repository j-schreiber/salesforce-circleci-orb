setup() {
    # source script under test
    source ./src/scripts/package-get-latest-build.sh

    # mock environment variables
    export PARAM_PACKAGE_ID="PACKAGE_ID"
    export PACKAGE_ID="0Ho08000000CaRqCAK"
    export PARAM_PACKAGE_VERSION_EXPORT="LATEST_PACKAGE_VERSION_ID"
    export PARAM_DEVHUB_USERNAME="info@lietzau-consulting.de"
    # false
    export PARAM_RELEASE_CANDIDATE=0

    # mock the CircleCI BASH_ENV and create an empty file there
    mkdir -p ~/circleci_bash_env
    export BASH_ENV=~/circleci_bash_env/mocked_bash_env.txt
    >"$BASH_ENV"

    # mock force:data:soql:query
    function sfdx_force_data_soql_query() {
        echo "SubscriberPackageVersionId"
        echo "04t080000000000AAA"
    }
}

teardown() {
    rm -f $BASH_ENV
}

@test "Default command config > has latest build > exports build" {
    # ACT
    run main

    # ASSERT
    exportedBashEnv=$(< $BASH_ENV)
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    echo "BASH_ENV: $exportedBashEnv"
    [ "$status" -eq 0 ]
    [ -f $BASH_ENV ]
    # found mocked subscriber package version id
    [[ "$output" == *"Exporting latest build 04t080000000000AAA to LATEST_PACKAGE_VERSION_ID"* ]]
    [[ $exportedBashEnv == 'export LATEST_PACKAGE_VERSION_ID=04t080000000000AAA' ]]
    # force:data:soql:query called for any build
    [[ "$output" != *"AND ValidationSkipped = false"* ]]
}

@test "Query release candidate only > has latest build > exports build" {
    # ARRANGE
    export PARAM_RELEASE_CANDIDATE=1

    # ACT
    run main

    # ASSERT
    exportedBashEnv=$(< $BASH_ENV)
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    echo "BASH_ENV: $exportedBashEnv"
    [ "$status" -eq 0 ]
    [ -f $BASH_ENV ]
    # found mocked subscriber package version id
    [[ "$output" == *"Exporting latest build 04t080000000000AAA to LATEST_PACKAGE_VERSION_ID"* ]]
    [[ $exportedBashEnv == 'export LATEST_PACKAGE_VERSION_ID=04t080000000000AAA' ]]
    # force:data:soql:query called for any build
    [[ "$output" == *"AND ValidationSkipped = false"* ]]
}

@test "Default command configuration > has no latest build > exits with error" {
    # ARRANGE
    # mock force:data:soql:query
    function sfdx_force_data_soql_query() {
        echo ""
    }

    # ACT
    run main

    # ASSERT
    exportedBashEnv=$(< $BASH_ENV)
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    echo "BASH_ENV: $exportedBashEnv"
    [ "$status" -eq 20 ]
    [ -f $BASH_ENV ]
    # found mocked subscriber package version id
    [[ "$output" == *"No build found for package. Aborting ..."* ]]
    [[ -z $exportedBashEnv ]]
}
