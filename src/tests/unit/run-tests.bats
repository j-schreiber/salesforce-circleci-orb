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

@test "Test execution fails > produces single output file and returns with exit code" {
    # ACT
    function execute_sf_apex_test_run() {
        echo "sf apex run test $*"
        echo "mock output" >> "$PARAM_OUTPUT_DIRECTORY/test-run-mock-junit.xml"
        echo "mock output" >> "$PARAM_OUTPUT_DIRECTORY/test-run-mock.json"
        echo "mock output" >> "$PARAM_OUTPUT_DIRECTORY/test-result.txt"
        echo "mock output" >> "$PARAM_OUTPUT_DIRECTORY/test-run-id.txt"
        return 100
    }
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    numberOfFiles=$( ls -1q $(pwd)/$PARAM_OUTPUT_DIRECTORY | wc -l )
    echo "Files found in $(pwd)/$PARAM_OUTPUT_DIRECTORY: $numberOfFiles"
    [ "$status" -eq 100 ]
    [[ $numberOfFiles -eq 1 ]]
}
