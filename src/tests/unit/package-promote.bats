setup() {
    # source script under test
    source ./src/scripts/package-promote.sh

    # mock default environment variables
    export ENV_VAR_PACKAGE_VERSION_ID="SUBSCRIBER_PACKAGE_VERSION_ID"
    export ENV_VAR_PACKAGE_ID="PACKAGE_ID"
    export SUBSCRIBER_PACKAGE_VERSION_ID=
    export PACKAGE_ID=
    export PARAM_PROMOTE_LATEST_BUILD=1
    export PARAM_DEVHUB_USERNAME="info@lietzau-consulting.de"
    # we cannot execute from within an sfdx project
    export PARAM_PATH="salesforce/demo-package"
}

@test "Promote latest build > Package version from query promoted" {
    # ARRANGE
    export PACKAGE_ID="0Ho08000000CaRqCAK"
    function query_latest_package_build() {
        cat src/tests/data/latest-package-build.json
    }
    function sfdx_package_version_promote() {
        echo "sfdx force:package:version:promote $@"
    }

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Promoting latest build 04t9Y0000000000AAA"* ]]
    [[ "$output" != *"Promoting specific build 04t9Y0000000000AAA from SUBSCRIBER_PACKAGE_VERSION"* ]]
    [[ "$output" == *"sfdx force:package:version:promote --package 04t9Y0000000000AAA --targetdevhubusername $PARAM_DEVHUB_USERNAME"* ]]
}

@test "Promote latest build > No build found > Exit with error" {
    # ARRANGE
    export PACKAGE_ID="0Ho08000000CaRqCAK"
    function query_latest_package_build() {
        cat src/tests/data/empty-query-result.json
    }
    function sfdx_package_version_promote() {
        echo "sfdx force:package:version:promote $@"
    }

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 20 ]
    [[ "$output" == *"No valid package version retrieved. Exiting ..."* ]]
    [[ "$output" != *"sfdx force:package:version:promote"* ]]
}

@test "Promote specific package version > Package version from input promoted" {
    # ARRANGE
    export SUBSCRIBER_PACKAGE_VERSION_ID="04t080000000000AAA"
    export PARAM_PROMOTE_LATEST_BUILD=0

    # ACT
    function sfdx_package_version_promote() {
        echo "sfdx force:package:version:promote $@"
    }
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" != *"Promoting latest build 04t080000000000AAA"* ]]
    [[ "$output" == *"Promoting specific build 04t080000000000AAA"* ]]
    # promotes package version
    [[ "$output" == *"sfdx force:package:version:promote --package 04t080000000000AAA --targetdevhubusername $PARAM_DEVHUB_USERNAME"* ]]
}

@test "Promote latest is false and no package version set > Exit with error" {
    # ARRANGE
    export PARAM_PROMOTE_LATEST_BUILD=0
    # export SUBSCRIBER_PACKAGE_VERSION_ID=

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 10 ]
    [[ "$output" == "The environment variable SUBSCRIBER_PACKAGE_VERSION_ID is empty"* ]]
}

@test "Promote latest is true and no package set > Exit with error" {
    # ARRANGE
    export PARAM_PROMOTE_LATEST_BUILD=1
    # export PACKAGE_ID=

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 11 ]
    [[ "$output" == "The environment variable PACKAGE_ID is empty"* ]]
}
