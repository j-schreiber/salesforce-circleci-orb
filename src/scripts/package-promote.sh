#! /bin/bash

verify_params() {
    if [ -z "${!ENV_VAR_PACKAGE_VERSION_ID}" ] && [ "${PARAM_PROMOTE_LATEST_BUILD}" -eq 0 ]; then
        echo "The environment variable ${ENV_VAR_PACKAGE_VERSION_ID} is empty, but the command was set to promote a specific package version. Export a package version or promote the latest build instead." >&2
        exit 10
    fi
    if [ -z "${!ENV_VAR_PACKAGE_ID}" ] && [ "${PARAM_PROMOTE_LATEST_BUILD}" -eq 1 ]; then
        echo "The environment variable ${ENV_VAR_PACKAGE_ID} is empty, but the command was set to promote the latest package version." >&2
        exit 11
    fi
}

query_latest_package_build() {
    queryString="SELECT SubscriberPackageVersionId FROM Package2Version WHERE Package2Id = '${!ENV_VAR_PACKAGE_ID}' AND ValidationSkipped = false ORDER BY CreatedDate DESC LIMIT 1"
    sfdx force:data:soql:query -t -q "$queryString" -u "${PARAM_DEVHUB_USERNAME}" -r csv | sed "1 d"
}

sfdx_package_version_promote() {
    echo "sfdx force:package:beta:version:promote $*"
    sfdx force:package:beta:version:promote "$@"
}

get_package_version_id() {
    if [ "${PARAM_PROMOTE_LATEST_BUILD}" -eq 0 ]; then
        echo "Promoting specific build ${!ENV_VAR_PACKAGE_VERSION_ID} from ${ENV_VAR_PACKAGE_VERSION_ID}"
        packageVersionId="${!ENV_VAR_PACKAGE_VERSION_ID}"
    else
        echo "No specific build set. Promoting latest release candidate for ${!ENV_VAR_PACKAGE_ID} ..."
        packageVersionId=$( query_latest_package_build )
        echo "Promoting latest build $packageVersionId"
    fi
}

promote_build() {
    if [ -z "$packageVersionId" ]; then
        echo "No valid package version retrieved. Exiting ..." >&2
        exit 20
    fi
    params=()
    params+=(--package "$packageVersionId")
    params+=( --targetdevhubusername "$PARAM_DEVHUB_USERNAME")
    params+=( --noprompt)
    sfdx_package_version_promote "${params[@]}"
}

main() {
    verify_params
    get_package_version_id
    promote_build
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    if [ -n "$PARAM_PATH" ]; then
        cd "$PARAM_PATH" || exit
    fi
    main
fi
