setup() {
    # source script under test
    source ./src/scripts/run-test-suites.sh

    # mock environment variables
    export PARAM_TARGET_ORG="info@lietzau-consulting.de"
    export PARAM_OUTPUT_DIRECTORY="test-results/apex"
    export PARAM_TEST_SUITES=

    function execute_sfdx_apex_test_run() {
        echo "sfdx force:apex:test:run $*"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/$2-test-run-mock-junit.xml"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/$2-test-run-mock.json"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/test-result.txt"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/test-run-id.txt"
    }
    export -f execute_sfdx_apex_test_run

    # default mock output
    function query_test_suites_from_target_org() {
        echo "TestSuite1" >> /tmp/test-suites.csv
        echo "TestSuite2" >> /tmp/test-suites.csv
        echo "TestSuite3" >> /tmp/test-suites.csv
    }
    export -f query_test_suites_from_target_org
}

teardown() {
    rm -f /tmp/test-suites.csv
    rm -rf $(pwd)/$PARAM_OUTPUT_DIRECTORY
}

@test "No test suites set > Query test suites from org > All suites executed" {
    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    numberOfFiles=$( ls -1q $(pwd)/$PARAM_OUTPUT_DIRECTORY | wc -l )
    echo "Files found in $(pwd)/$PARAM_OUTPUT_DIRECTORY: $numberOfFiles"
    [ "$status" -eq 0 ]
    [[ $output == *"--suitenames TestSuite1"* ]]
    [[ $output == *"--suitenames TestSuite2"* ]]
    [[ $output == *"--suitenames TestSuite3"* ]]
    [[ $numberOfFiles -eq 3 ]]
}

@test "Test suites set as parameter > Input test suites executed" {
    # ARRANGE
    PARAM_TEST_SUITES="TestSuite3 TestSuite4 TestSuite5"

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    numberOfFiles=$( ls -1q $(pwd)/$PARAM_OUTPUT_DIRECTORY | wc -l )
    echo "Files found in $(pwd)/$PARAM_OUTPUT_DIRECTORY: $numberOfFiles"
    [ "$status" -eq 0 ]
    [[ $output == *"--suitenames TestSuite3"* ]]
    [[ $output == *"--suitenames TestSuite4"* ]]
    [[ $output == *"--suitenames TestSuite5"* ]]
    [[ $numberOfFiles -eq 3 ]]
}

@test "Lists of test suites set as parameter > Input test suites executed" {
    # ARRANGE
    PARAM_TEST_SUITES="TestSuite3,TestSuite4 TestSuite5,TestSuite1"

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    numberOfFiles=$( ls -1q $(pwd)/$PARAM_OUTPUT_DIRECTORY | wc -l )
    echo "Files found in $(pwd)/$PARAM_OUTPUT_DIRECTORY: $numberOfFiles"
    [ "$status" -eq 0 ]
    [[ $output == *"--suitenames TestSuite3,TestSuite4"* ]]
    [[ $output == *"--suitenames TestSuite5,TestSuite1"* ]]
    [[ $numberOfFiles -eq 2 ]]
}

@test "One test suite fails > Failing exit code is final exit code" {
    # ARRANGE
    PARAM_TEST_SUITES="TestSuite3 TestSuite4 TestSuite5"

    # ACT
    function execute_sfdx_apex_test_run() {
        echo "sfdx force:apex:test:run $*"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/$2-test-run-mock-junit.xml"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/$2-test-run-mock.json"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/test-result.txt"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/test-run-id.txt"
        # $1 = --suitenames; $2 = <TestSuiteName>
        if [[ $2 == "TestSuite4" ]]; then
            return 100
        fi
        return 0
    }
    export -f execute_sfdx_apex_test_run
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    numberOfFiles=$( ls -1q $(pwd)/$PARAM_OUTPUT_DIRECTORY | wc -l )
    echo "Files found in $(pwd)/$PARAM_OUTPUT_DIRECTORY: $numberOfFiles"
    [ "$status" -eq 100 ]
    [[ $output == *"--suitenames TestSuite3"* ]]
    [[ $output == *"--suitenames TestSuite4"* ]]
    [[ $output == *"--suitenames TestSuite5"* ]]
    [[ $numberOfFiles -eq 3 ]]
}

@test "All test suits fail > Failing exit code is final exit code" {
    # ARRANGE
    PARAM_TEST_SUITES="TestSuite3 TestSuite4 TestSuite5"

    # ACT
    function execute_sfdx_apex_test_run() {
        echo "sfdx force:apex:test:run $*"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/$2-test-run-mock-junit.xml"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/$2-test-run-mock.json"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/test-result.txt"
        echo "$2" >> "$PARAM_OUTPUT_DIRECTORY/test-run-id.txt"
        return 100
    }
    export -f execute_sfdx_apex_test_run
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    numberOfFiles=$( ls -1q $(pwd)/$PARAM_OUTPUT_DIRECTORY | wc -l )
    echo "Files found in $(pwd)/$PARAM_OUTPUT_DIRECTORY: $numberOfFiles"
    [ "$status" -eq 100 ]
    [[ $output == *"--suitenames TestSuite3"* ]]
    [[ $output == *"--suitenames TestSuite4"* ]]
    [[ $output == *"--suitenames TestSuite5"* ]]
    [[ $numberOfFiles -eq 3 ]]
}
