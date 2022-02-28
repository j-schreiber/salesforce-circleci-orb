setup() {
    # source script under test
    source ./src/scripts/run-tests.sh

    # mock environment variables
    export PARAM_TARGET_ORG="info@lietzau-consulting.de"
    export PARAM_OUTPUT_DIRECTORY="test-results/all-apex"
}

teardown() {
    rm -f expected-test-suites.csv
    rm -rf $(pwd)/$PARAM_OUTPUT_DIRECTORY
}

@test "Execute success tests on org > produces a single output file" {
    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    numberOfFiles=$( ls -1q $(pwd)/$PARAM_OUTPUT_DIRECTORY | wc -l )
    echo "Files found in $(pwd)/$PARAM_OUTPUT_DIRECTORY: $numberOfFiles"
    [ "$status" -eq 0 ]
    [[ $numberOfFiles -eq 1 ]]
}
