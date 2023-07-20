#! /bin/bash

setup_output_directory() {
    mkdir -p "$PARAM_OUTPUT_DIRECTORY"
}

execute_sf_apex_test_run() {
    echo "sf apex run test $*"
    sf apex run test "$@"
}

run_tests() {
    params=()
    params+=( --target-org "$PARAM_TARGET_ORG")
    params+=( --wait 10)
    params+=( --result-format junit)
    params+=( --output-dir "$PARAM_OUTPUT_DIRECTORY")
    execute_sf_apex_test_run "${params[@]}"
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
