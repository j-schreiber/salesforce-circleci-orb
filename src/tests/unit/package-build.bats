setup() {
    # source script under test
    source ./src/scripts/package-build.sh

    # initialise with defaults from src/commands/package-install.yml
    export PARAM_PACKAGE=PACKAGE
    export PACKAGE=0Ho08000000CaRqCAK
    export PARAM_INSTALLATION_KEY=INSTALLATION_KEY
    export INSTALLATION_KEY="abc"
    export PARAM_DEV_HUB=
    export PARAM_PATH=salesforce
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
}

function build_success_message() {
    echo "sfdx-project.json has been updated."
    echo "Successfully created the package version [08c08000000CajLAAS]. Subscriber Package Version Id: 04t08000000gZPYAA2"
    echo "Package Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t08000000gZPYAA2"
    echo "As an alternative, you can use the \"sfdx force:package:install\" command."
}

function build_package_success_mock() {
    echo "sfdx force:package:version:create $@"
    echo "Request in progress. Sleeping 5 seconds. Will wait a total of 3600 more seconds before timing out. Current Status='Queued'"
    build_success_message
}

function build_package_with_dependencies_mock() {
    echo "sfdx force:package:version:create $@"
    echo "Dependency on package XXX was resolved to version number 1.2.3.4, branch null, 04t670000001111AAQ."
    echo "Dependency on package YYY was resolved to version number 1.3.4.5, branch null, 04t670000002222AAQ."
    echo "Request in progress. Sleeping 5 seconds. Will wait a total of 3600 more seconds before timing out. Current Status='Queued'"
    build_success_message
}

function build_package_error() {
    echo "sfdx force:package:version:create $@"
    echo "Dependency on package XXX was resolved to version number 1.2.3.4, branch null, 04t67000000bg2OAAQ."
    echo "Request in progress. Sleeping 30 seconds. Will wait a total of 3600 more seconds before timing out. Current Status='Initializing'"
    echo "Request in progress. Sleeping 30 seconds. Will wait a total of 3570 more seconds before timing out. Current Status='Initializing'"
    echo "Request in progress. Sleeping 30 seconds. Will wait a total of 3540 more seconds before timing out. Current Status='Verifying features and settings'"
    echo "Request in progress. Sleeping 30 seconds. Will wait a total of 3510 more seconds before timing out. Current Status='Verifying dependencies'"
    echo "Request in progress. Sleeping 30 seconds. Will wait a total of 3480 more seconds before timing out. Current Status='Verifying dependencies'"
    echo "Request in progress. Sleeping 30 seconds. Will wait a total of 3450 more seconds before timing out. Current Status='Verifying dependencies'"
    echo "ERROR running force:package:version:create:  Multiple errors occurred:"
    echo "(1) PimsProductFactory: Dependent class is invalid and needs recompilation:"
    echo "Class ProductDomainExtension : Variable does not exist: DateUtils"
    echo "(2) ProductDomain: Dependent class is invalid and needs recompilation:"
}

function build_package_timeout() {
    echo "sfdx force:package:version:create $@"
    echo "Request in progress. Sleeping 30 seconds. Will wait a total of 90 more seconds before timing out. Current Status='Initializing'"
    echo "Request in progress. Sleeping 30 seconds. Will wait a total of 60 more seconds before timing out. Current Status='Verifying metadata'"
    echo "Request in progress. Sleeping 30 seconds. Will wait a total of 30 more seconds before timing out. Current Status='Finalizing package version'"
    echo "Package version creation request status is 'Finalizing package version'. Run sfdx force:package:version:create:report -i 08c08000000CakYAAS to query for status."
}

@test "Default command initialisation > Builds beta package and exports to BASH_ENV" {
    # ARRANGE
    export PARAM_PACKAGE_VERSION_EXPORT=MY_SUBSCRIBER_PACKAGE_VERSION_ID

    # ACT
    # mock force:package:version:create with a successful package create request
    function build_package_with_parameters() {
        build_package_success_mock $@
    }
    export -f build_package_with_parameters
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [ -f $BASH_ENV ]
    # prints sfdx command output
    [[ "$output" == *"--installationkey $INSTALLATION_KEY"* ]]
    [[ "$output" == *"Successfully created the package version [08c08000000CajLAAS]"* ]]
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ $exportedBashEnv == 'export MY_SUBSCRIBER_PACKAGE_VERSION_ID=04t08000000gZPYAA2' ]]
}

@test "No package version export specify > Builds beta package" {
    # ARRANGE
    export PARAM_PACKAGE_VERSION_EXPORT=

    # ACT
    # mock force:package:version:create with a successful package create request
    function build_package_with_parameters() {
        build_package_success_mock $@
    }
    export -f build_package_with_parameters
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    # prints sfdx command output
    [[ "$output" == *"Successfully created the package version [08c08000000CajLAAS]"* ]]
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ -z $exportedBashEnv ]]
}

@test "Package version create timed out with export specified > Abort with exit code" {
    # ARRANGE
    export PARAM_PACKAGE_VERSION_EXPORT=MY_PGK_VAR

    # ACT
    # mock force:package:version:create with a successful package create request
    function build_package_with_parameters() {
        build_package_timeout $@
    }
    export -f build_package_with_parameters
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 100 ]
    # prints sfdx command output
    [[ "$output" == *"Package version creation request status is 'Finalizing package version'."* ]]
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ -z $exportedBashEnv ]]
}

@test "Package version create timed out without export specified > Succeed" {
    # ARRANGE
    export PARAM_PACKAGE_VERSION_EXPORT=

    # ACT
    # mock force:package:version:create with a successful package create request
    function build_package_with_parameters() {
        build_package_timeout $@
    }
    export -f build_package_with_parameters
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 100 ]
    # prints sfdx command output
    [[ "$output" == *"Package version creation request status is 'Finalizing package version'."* ]]
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ -z $exportedBashEnv ]]
}

@test "Create package version with installation key bypass > Does not use installation key" {
    # ARRANGE
    export PARAM_PACKAGE_VERSION_EXPORT=MY_SUBSCRIBER_PACKAGE_VERSION_ID
    export PARAM_REQUIRE_KEY=0

    # ACT
    # mock force:package:version:create with a successful package create request
    function build_package_with_parameters() {
        build_package_success_mock $@
    }
    export -f build_package_with_parameters
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [ -f $BASH_ENV ]
    # prints sfdx command output
    [[ "$output" != *"--installationkey $INSTALLATION_KEY"* ]]
    [[ "$output" = *"--installationkeybypass"* ]]
    [[ "$output" == *"Successfully created the package version [08c08000000CajLAAS]"* ]]
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ $exportedBashEnv == 'export MY_SUBSCRIBER_PACKAGE_VERSION_ID=04t08000000gZPYAA2' ]]
}

@test "Package version create with dependency > Export created version" {
    # ACT
    # mock force:package:version:create with a successful package create request
    function build_package_with_parameters() {
        build_package_with_dependencies_mock $@
    }
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [ -f $BASH_ENV ]
    # prints sfdx command output
    [[ "$output" == *"Successfully created the package version [08c08000000CajLAAS]"* ]]
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ $exportedBashEnv == 'export SUBSCRIBER_PACKAGE_VERSION_ID=04t08000000gZPYAA2' ]]
}

@test "Package version fails with error > Command exits with error code" {
    # ACT
    # mock force:package:version:create with a failing package create request
    function build_package_with_parameters() {
        build_package_error $@
        exit 1
    }
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    # error from analysing command output
    [ "$status" -eq 100 ]
    [ -f $BASH_ENV ]
    # prints sfdx command output
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ -z $exportedBashEnv ]]
}

