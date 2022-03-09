#! /bin/bash

sfdx_force_source_deploy() {
    echo "sfdx force:source:deploy $*"
    sfdx force:source:deploy "$@"
}

is_sandbox_org() {
    sfdx force:data:soql:query -q "SELECT IsSandbox FROM Organization LIMIT 1" -u "$PARAM_TARGET_ORG" -r csv | sed "1 d"
}

deploy() {
    params=()
    params+=( --sourcepath "$1")
    params+=( --targetusername "$PARAM_TARGET_ORG")
    isSandbox=$( is_sandbox_org )
    if [ "$isSandbox" == 'false' ]; then
        params+=(--testlevel RunLocalTests)
    fi
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
