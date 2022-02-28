setup() {
    # source script under test
    source ./src/scripts/run-test-suites.sh

    # mock environment variables
    export PARAM_TARGET_ORG="info@lietzau-consulting.de"
    export PARAM_OUTPUT_DIRECTORY="test-results/apex"
    export PARAM_TEST_SUITES=
}

teardown() {
    rm -f expected-test-suites.csv
    rm -rf $(pwd)/$PARAM_OUTPUT_DIRECTORY
}

@test "No test suites set > Query test suites from org > All suites executed" {
    # ARRANGE
    sfdx force:data:soql:query -q "SELECT TestSuiteName FROM ApexTestSuite" -r csv -u "$PARAM_TARGET_ORG" | sed "1 d" > expected-test-suites.csv
    expectedExecutionsCount=$( cat expected-test-suites.csv | wc -l )
    
    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    numberOfFiles=$( ls -1q $(pwd)/$PARAM_OUTPUT_DIRECTORY | wc -l )
    echo "Files found in $(pwd)/$PARAM_OUTPUT_DIRECTORY: $numberOfFiles"
    [ "$status" -eq 0 ]
    while read -r testSuite
    do
        [[ $output == *"--suitenames $testSuite"* ]]
    done < expected-test-suites.csv
    [[ $numberOfFiles -eq $expectedExecutionsCount ]]
}

@test "Test suites set as parameter > Input test suites executed" {
    # ARRANGE
    PARAM_TEST_SUITES="TestSuite1,TestSuite2 TestSuite3"
    echo "TestSuite1,TestSuite2" >> expected-test-suites.csv
    echo "TestSuite3" >> expected-test-suites.csv

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    numberOfFiles=$( ls -1q $(pwd)/$PARAM_OUTPUT_DIRECTORY | wc -l )
    echo "Files found in $(pwd)/$PARAM_OUTPUT_DIRECTORY: $numberOfFiles"
    [ "$status" -eq 0 ]
    while read -r testSuite
    do
        [[ $output == *"--suitenames $testSuite"* ]]
    done < expected-test-suites.csv
    [[ $numberOfFiles -eq 2 ]]
}
