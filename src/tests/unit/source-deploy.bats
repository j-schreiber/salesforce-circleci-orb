setup() {
    # source script under test
    source ./src/scripts/source-deploy.sh

    # mock environment variables
    export PARAM_TARGET_ORG="info@lietzau-consulting.de"
    export PARAM_DIRECTORIES=
    export PARAM_OVERRIDES=
    export PARAM_PROJECT_PATH=

    # mock sfdx deploy
    function sfdx_force_source_deploy() {
        echo "sfdx force:source:deploy $*"
    }

    # mock sfdx query
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
    [[ $output == *"sfdx force:source:deploy --sourcepath src/deploy --targetusername info@lietzau-consulting.de"* ]]
}

@test "Deploy single directory > production org > deploys with RunLocalTests" {
    # ARRANGE
    export PARAM_DIRECTORIES='src/deploy'
    function is_sandbox_org() {
        echo "false"
    }

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"sfdx force:source:deploy --sourcepath src/deploy --targetusername info@lietzau-consulting.de --testlevel RunLocalTests"* ]]
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
    [[ $output == *"sfdx force:source:deploy --sourcepath src/deploy --targetusername info@lietzau-consulting.de"* ]]
    [[ $output == *"sfdx force:source:deploy --sourcepath src/deploy-two --targetusername info@lietzau-consulting.de"* ]]
    [[ $output == *"sfdx force:source:deploy --sourcepath src/deploy-three --targetusername info@lietzau-consulting.de"* ]]
}

@test "Deploy with overrides > override config executed" {
    # ARRANGE
    export PARAM_OVERRIDES='-u info@lietzau-consulting.de -p src/deploy-one -w 10 -l RunLocalTests'

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"sfdx force:source:deploy -u info@lietzau-consulting.de -p src/deploy-one -w 10 -l RunLocalTests"* ]]
}
