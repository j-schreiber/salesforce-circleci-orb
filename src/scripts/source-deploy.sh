#! /bin/bash

sfdx_force_source_deploy() {
    echo "sf project deploy start $*"
    sf project deploy start "$@"
}

deploy() {
    params=()
    params+=( --source-dir "$1")
    params+=( --target-org "$PARAM_TARGET_ORG")
    params+=( --test-level RunLocalTests)
    sfdx_force_source_deploy "${params[@]}"
}

main() {
    if [ -n "$PARAM_PROJECT_PATH" ]; then
        cd "$PARAM_PROJECT_PATH" || exit 1
    fi
    if [ -n "$PARAM_OVERRIDES" ]; then
        sfdx_force_source_deploy "$PARAM_OVERRIDES"
        exit
    fi
    IFS=" " read -r -a dirs <<< "$PARAM_DIRECTORIES"
    for dir in "${dirs[@]}"
    do
        deploy "$dir"
    done
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi
