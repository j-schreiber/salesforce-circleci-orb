setup() {
    # source script under test
    source ./src/scripts/package-build.sh

    # initialise with defaults from src/commands/package-install.yml
    export PARAM_PACKAGE=PACKAGE
    export PACKAGE=0Ho08000000CaRqCAK
    export PARAM_INSTALLATION_KEY=INSTALLATION_KEY
    export INSTALLATION_KEY="abc"
    export PARAM_DEV_HUB=
    export PARAM_PATH=salesforce/demo-package
    export PARAM_PACKAGE_VERSION_EXPORT=SUBSCRIBER_PACKAGE_VERSION_ID
    # false
    export PARAM_IS_RELEASE_CANDIDATE=0
    # true
    export PARAM_REQUIRE_KEY=1

    # mock the CircleCI BASH_ENV and create an empty file there
    mkdir -p ~/circleci_bash_env
    export BASH_ENV=~/circleci_bash_env/mocked_bash_env.txt
    >"$BASH_ENV"
}

teardown() {
    rm -f $BASH_ENV
    rm -f salesforce/demo-package/package_version_create_result.json
}

@test "Default command initialisation > Builds beta package and exports to BASH_ENV" {
    # Arrange
    function sf_package_version_create() {
        cat ../../src/tests/data/package-build-rc-success.json
    }

    # Act
    run main

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [ -f $BASH_ENV ]
    # prints sf command output
    [[ "$output" == *"--installation-key $INSTALLATION_KEY"* ]]
    [[ "$output" == *"Successfully created new package version: 04t68000000l0mpAAA"* ]]
    [[ "$output" == *"Exporting new package version 04t68000000l0mpAAA to SUBSCRIBER_PACKAGE_VERSION_ID"* ]]
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ $exportedBashEnv == 'export SUBSCRIBER_PACKAGE_VERSION_ID=04t68000000l0mpAAA' ]]
}

@test "No package version export specified > Builds beta package without exporting" {
    # Arrange
    export PARAM_PACKAGE_VERSION_EXPORT=
    function sf_package_version_create() {
        cat ../../src/tests/data/package-build-rc-success.json
    }

    # Act
    run main

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Successfully created new package version: 04t68000000l0mpAAA"* ]]
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ -z $exportedBashEnv ]]
}

@test "Package version create timed out with export specified > Abort with exit code" {
    # Arrange
    function sf_package_version_create() {
        cat ../../src/tests/data/package-build-rc-timeout.json
    }

    # Act
    run main

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 101 ]
    # prints sf command output
    [[ "$output" == *"Package build timed out with status: Initializing"* ]]
    [[ "$output" == *"Export specified but no package version created. Exit with 101"* ]]
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ -z $exportedBashEnv ]]
}

@test "Package version create timed out without export specified > Succeed" {
    # Arrange
    export PARAM_PACKAGE_VERSION_EXPORT=
    function sf_package_version_create() {
        cat ../../src/tests/data/package-build-rc-timeout.json
    }

    # Act
    run main

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    # prints sf command output
    [[ "$output" == *"Package build timed out with status: Initializing"* ]]
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ -z $exportedBashEnv ]]
}

@test "Create package version with installation key bypass > Does not use installation key" {
    # Arrange
    export PARAM_PACKAGE_VERSION_EXPORT=MY_SUBSCRIBER_PACKAGE_VERSION_ID
    export PARAM_REQUIRE_KEY=0

    function sf_package_version_create() {
        cat ../../src/tests/data/package-build-rc-success.json
    }

    # Act
    run main

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [ -f $BASH_ENV ]
    # prints sf command output
    [[ "$output" != *"--installation-key $INSTALLATION_KEY"* ]]
    [[ "$output" = *"--installation-key-bypass"* ]]
    [[ "$output" == *"Exporting new package version 04t68000000l0mpAAA to MY_SUBSCRIBER_PACKAGE_VERSION_ID"* ]]
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ $exportedBashEnv == 'export MY_SUBSCRIBER_PACKAGE_VERSION_ID=04t68000000l0mpAAA' ]]
}

@test "Package version fails with error > Command exits with error code" {
    # Arrange
    function sf_package_version_create() {
        cat ../../src/tests/data/package-build-rc-error.json
        exit 1
    }
    
    # Act
    run main

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    # error from analysing command output
    [ "$status" -eq 100 ]
    [[ "$output" == *"Package build failed with message: Mock Error Message"* ]]
    [ -f $BASH_ENV ]
    # prints sf command output
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ -z $exportedBashEnv ]]
}

