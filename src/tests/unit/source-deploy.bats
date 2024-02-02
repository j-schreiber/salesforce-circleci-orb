setup() {
    # source script under test
    source ./src/scripts/source-deploy.sh

    # mock environment variables
    export PARAM_TARGET_ORG="info@lietzau-consulting.de"
    export PARAM_DIRECTORIES=
    export PARAM_OVERRIDES=
    export PARAM_PROJECT_PATH=

    # mock sf deploy
    function sf_project_deploy_start() {
        echo "sf project deploy start $*"
    }

    # mock sf query
    function is_sandbox_org() {
        echo "true"
    }
}

@test "Deploy single directory > No overrides > one source deploy executed" {
    # ARRANGE
    export PARAM_DIRECTORIES='src/deploy'

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"sf project deploy start --source-dir src/deploy --target-org info@lietzau-consulting.de --test-level RunLocalTests --verbose" ]]
}

@test "Deploy multiple directories > No overrides > all source deployed" {
    # ARRANGE
    export PARAM_DIRECTORIES='src/deploy src/deploy-two src/deploy-three'

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"sf project deploy start --source-dir src/deploy --target-org info@lietzau-consulting.de --test-level RunLocalTests --verbose"* ]]
    [[ $output == *"sf project deploy start --source-dir src/deploy-two --target-org info@lietzau-consulting.de --test-level RunLocalTests --verbose"* ]]
    [[ $output == *"sf project deploy start --source-dir src/deploy-three --target-org info@lietzau-consulting.de --test-level RunLocalTests --verbose"* ]]
}

@test "Deploy with overrides > override config executed" {
    # ARRANGE
    export PARAM_OVERRIDES='-o info@lietzau-consulting.de -d src/deploy-one -w 10 -l RunLocalTests'

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"sf project deploy start -o info@lietzau-consulting.de -d src/deploy-one -w 10 -l RunLocalTests" ]]
}
