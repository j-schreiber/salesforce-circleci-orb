#! /bin/bash

setup_output_directory() {
    mkdir -p "$PARAM_OUTPUT_DIRECTORY"
}

prepare_test_suites_for_execution() {
    rm -f /tmp/test-suites.csv
    if [[ -n $PARAM_TEST_SUITES ]]; then
        write_test_suites_to_csv "$PARAM_TEST_SUITES"
    else
        query_test_suites_from_target_org
    fi
    echo "Executing the following test suites:"
    cat /tmp/test-suites.csv
}

write_test_suites_to_csv() {
    IFS=" " read -r -a testSuites <<< "$1"
    for testSuite in "${testSuites[@]}"
    do
        echo "$testSuite" >> /tmp/test-suites.csv
    done
}

query_test_suites_from_target_org() {
    sfdx force:data:soql:query -q "SELECT TestSuiteName FROM ApexTestSuite" -r csv -u "$PARAM_TARGET_ORG" | sed "1 d" > /tmp/test-suites.csv
}

execute_sfdx_apex_test_run() {
    echo "sfdx force:apex:test:run $*"
    sfdx force:apex:test:run "$@"
}

run_test_suite() {
    echo ""
    echo "====== $1 ======"
    params=()
    params+=(--suitenames "$1")
    params+=( --targetusername "$PARAM_TARGET_ORG")
    params+=( --wait 10)
    params+=( --resultformat junit)
    params+=( --outputdir "$PARAM_OUTPUT_DIRECTORY")
    execute_sfdx_apex_test_run "${params[@]}"
    exitCode=$?
    rm -f "$PARAM_OUTPUT_DIRECTORY"/test-result.xml
    rm -f "$PARAM_OUTPUT_DIRECTORY"/*.json
    rm -f "$PARAM_OUTPUT_DIRECTORY"/*.txt
    echo ">>>>>> Test suite $1 exited with code: $exitCode"
    return $exitCode
}

main() {
    set +e
    finalExitCode=0
    setup_output_directory
    prepare_test_suites_for_execution
    while read -r testSuite
    do
        run_test_suite "$testSuite"
        exitCode=$?
        if [[ $exitCode != '0' ]]; then
            finalExitCode=$exitCode
        fi
    done < /tmp/test-suites.csv
    set -e
    return $finalExitCode
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi
