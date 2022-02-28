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


@test "Default command > Retrieve package from target org > retrieved version Id exported" {
    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [ -f $BASH_ENV ]
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ $exportedBashEnv == 'export INSTALLED_PACKAGE_VERSION_ID=04t'* ]]
}
