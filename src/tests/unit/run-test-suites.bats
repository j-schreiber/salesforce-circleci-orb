setup() {
    # source script under test
    source ./src/scripts/run-test-suites.sh

    # mock environment variables
    export PARAM_TARGET_ORG="info@lietzau-consulting.de"
    export PARAM_OUTPUT_DIRECTORY="test-results/apex"
    export PARAM_TEST_SUITES=

    function sf_apex_test_run() {
        echo "sf apex run test $*"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/$2-test-run-mock-junit.xml"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/$2-test-run-mock.json"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/test-result.txt"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/test-run-id.txt"
    }
}

teardown() {
    rm -f /tmp/test-suites.csv
    rm -rf $(pwd)/$PARAM_OUTPUT_DIRECTORY
}

@test "No test suites set > Query test suites from org > All suites executed" {
    # Arrange
    function query_test_suites_from_target_org() {
        cat src/tests/data/test-suites.json
    }

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    numberOfFiles=$( ls -1q $(pwd)/$PARAM_OUTPUT_DIRECTORY | wc -l )
    echo "Files found in $(pwd)/$PARAM_OUTPUT_DIRECTORY: $numberOfFiles"
    [ "$status" -eq 0 ]
    [[ $output == *"--suite-names TestSuite1"* ]]
    [[ $output == *"--suite-names TestSuite2"* ]]
    [[ $output == *"--suite-names TestSuite3"* ]]
    [[ $numberOfFiles -eq 3 ]]
}

@test "Test suites set as parameter > Input test suites executed" {
    # ARRANGE
    PARAM_TEST_SUITES="Test_Suite_3 Test_Suite_4 Test_Suite_5"

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    numberOfFiles=$( ls -1q $(pwd)/$PARAM_OUTPUT_DIRECTORY | wc -l )
    echo "Files found in $(pwd)/$PARAM_OUTPUT_DIRECTORY: $numberOfFiles"
    [ "$status" -eq 0 ]
    [[ $output == *"--suite-names Test_Suite_3"* ]]
    [[ $output == *"--suite-names Test_Suite_4"* ]]
    [[ $output == *"--suite-names Test_Suite_5"* ]]
    [[ $numberOfFiles -eq 3 ]]
}

@test "Lists of test suites set as parameter > Input test suites executed" {
    # ARRANGE
    PARAM_TEST_SUITES="Test_Suite_3,Test_Suite_4 Test_Suite_5,Test_Suite_1"

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    numberOfFiles=$( ls -1q $(pwd)/$PARAM_OUTPUT_DIRECTORY | wc -l )
    echo "Files found in $(pwd)/$PARAM_OUTPUT_DIRECTORY: $numberOfFiles"
    [ "$status" -eq 0 ]
    [[ $output == *"--suite-names Test_Suite_3,Test_Suite_4"* ]]
    [[ $output == *"--suite-names Test_Suite_5,Test_Suite_1"* ]]
    [[ $numberOfFiles -eq 2 ]]
}

@test "One test suite fails > Failing exit code is final exit code" {
    # ARRANGE
    PARAM_TEST_SUITES="Test_Suite_3 Test_Suite_4 Test_Suite_5"

    # ACT
    function sf_apex_test_run() {
        echo "sf apex run test $*"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/$2-test-run-mock-junit.xml"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/$2-test-run-mock.json"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/test-result.txt"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/test-run-id.txt"
        # $1 = --suite-names; $2 = <Test_Suite_Name>
        if [[ $2 == "Test_Suite_4" ]]; then
            return 100
        fi
        return 0
    }
    export -f sf_apex_test_run
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    numberOfFiles=$( ls -1q $(pwd)/$PARAM_OUTPUT_DIRECTORY | wc -l )
    echo "Files found in $(pwd)/$PARAM_OUTPUT_DIRECTORY: $numberOfFiles"
    [ "$status" -eq 100 ]
    [[ $output == *"--suite-names Test_Suite_3"* ]]
    [[ $output == *"--suite-names Test_Suite_4"* ]]
    [[ $output == *"--suite-names Test_Suite_5"* ]]
    [[ $numberOfFiles -eq 3 ]]
}

@test "All test suits fail > Failing exit code is final exit code" {
    # ARRANGE
    PARAM_TEST_SUITES="Test_Suite_3 Test_Suite_4 Test_Suite_5"

    # ACT
    function sf_apex_test_run() {
        echo "sf apex run test $*"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/$2-test-run-mock-junit.xml"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/$2-test-run-mock.json"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/test-result.txt"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/test-run-id.txt"
        return 100
    }
    export -f sf_apex_test_run
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    numberOfFiles=$( ls -1q $(pwd)/$PARAM_OUTPUT_DIRECTORY | wc -l )
    echo "Files found in $(pwd)/$PARAM_OUTPUT_DIRECTORY: $numberOfFiles"
    [ "$status" -eq 100 ]
    [[ $output == *"--suite-names Test_Suite_3"* ]]
    [[ $output == *"--suite-names Test_Suite_4"* ]]
    [[ $output == *"--suite-names Test_Suite_5"* ]]
    [[ $numberOfFiles -eq 3 ]]
}
