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
}

teardown() {
    rm -f $BASH_ENV
}

@test "Default command config > Exports latest build" {
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
    [[ "$output" == *"Exporting latest build"* ]]
    [[ $exportedBashEnv == 'export LATEST_PACKAGE_VERSION_ID='* ]]
    # force:data:soql:query called for any build
    [[ "$output" != *"AND ValidationSkipped = false"* ]]
}

@test "Query for release candidate > Exports latest build" {
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
    [[ "$output" == *"Exporting latest build"* ]]
    [[ $exportedBashEnv == 'export LATEST_PACKAGE_VERSION_ID='* ]]
    # force:data:soql:query called for any build
    [[ "$output" == *"AND ValidationSkipped = false"* ]]
}
