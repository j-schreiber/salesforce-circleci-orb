setup() {
    # source script under test
    source ./src/scripts/package-build.sh

    # initialise with defaults from src/commands/package-install.yml
    export PARAM_PACKAGE=PACKAGE
    export PACKAGE="Orb Developer Demo Package"
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
    # this allows us to assert on exported variables
    mkdir -p ~/circleci_bash_env
    export BASH_ENV=~/circleci_bash_env/mocked_bash_env.txt
    >"$BASH_ENV"
}

teardown() {
    rm -f $BASH_ENV
    rm -f salesforce/demo-package/package_version_create_result.json
    # sf updates sfdx-project.json after success
    cd salesforce/demo-package
    package_alias=$(jq '.packageAliases | keys[1]' sfdx-project.json)
    jq "del(.packageAliases.$package_alias)" sfdx-project.json > sfdx-project-copy.json
    mv sfdx-project-copy.json sfdx-project.json
    cd ../..
}

@test "Default command initialisation > Builds beta package and exports to BASH_ENV" {
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
    # [[ "$output" == *"WARNING: Skipping validation"* ]]
    [[ "$output" == *"Successfully created new package version: 04t"* ]]
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ $exportedBashEnv == 'export SUBSCRIBER_PACKAGE_VERSION_ID=04t'* ]]
}

@test "Build release candidate > Builds validated package and exports to BASH_ENV" {
    # Arrange
    # false
    export PARAM_IS_RELEASE_CANDIDATE=1

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
    # [[ "$output" != *"WARNING: Skipping validation"* ]]
    [[ "$output" == *"Successfully created new package version: 04t"* ]]
    exportedBashEnv=$(< $BASH_ENV)
    echo "BASH_ENV: $exportedBashEnv"
    [[ $exportedBashEnv == 'export SUBSCRIBER_PACKAGE_VERSION_ID=04t'* ]]
}
