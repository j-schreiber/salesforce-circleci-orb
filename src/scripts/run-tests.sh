#! /bin/bash

setup_output_directory() {
    mkdir -p "$PARAM_OUTPUT_DIRECTORY"
}

execute_sfdx_apex_test_run() {
    echo "sfdx force:apex:test:run $*"
    sfdx force:apex:test:run "$@"
}

run_tests() {
    params=()
    params+=( --targetusername "$PARAM_TARGET_ORG")
    params+=( --wait 10)
    params+=( --resultformat junit)
    params+=( --outputdir "$PARAM_OUTPUT_DIRECTORY")
    execute_sfdx_apex_test_run "${params[@]}"
    exitCode=$?
    rm -f "$PARAM_OUTPUT_DIRECTORY"/test-result.xml
    rm -f "$PARAM_OUTPUT_DIRECTORY"/*.json
    rm -f "$PARAM_OUTPUT_DIRECTORY"/*.txt
    return $exitCode
}

main() {
    setup_output_directory
    set +e
    run_tests
    return $?
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi
