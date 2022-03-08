#! /bin/bash

verify_params() {
    if [ -z "${!PARAM_PACKAGE_ID}" ]; then
        echo "The environment variable $PARAM_PACKAGE_ID is empty. Provide the package id" >&2
        exit 10
    fi
}

sfdx_force_data_soql_query() {
    sfdx force:data:soql:query "$@"
}

get_latest_package_build() {
    queryParamValSkipped=
    if [ "${PARAM_RELEASE_CANDIDATE}" -eq 1 ]; then
        queryParamValSkipped="AND ValidationSkipped = false"
    fi
    queryString="SELECT SubscriberPackageVersionId FROM Package2Version WHERE Package2Id = '${!PARAM_PACKAGE_ID}' $queryParamValSkipped ORDER BY CreatedDate DESC LIMIT 1"
    queryParams=()
    queryParams+=(-t)
    queryParams+=( -q "$queryString")
    queryParams+=( -u "${PARAM_DEVHUB_USERNAME}")
    queryParams+=( -r csv)
    echo "sfdx force:data:soql:query ${queryParams[*]}"
    installedPackageVersionId=$( sfdx_force_data_soql_query "${queryParams[@]}" | sed "1 d" )
}

export_package_version_id() {
    if [ -z "$1" ]; then
        echo "No build found for package. Aborting ..."
        exit 20
    else
        echo "Exporting latest build $1 to $PARAM_PACKAGE_VERSION_EXPORT"
        echo "export $PARAM_PACKAGE_VERSION_EXPORT=$1" >> "$BASH_ENV"
    fi
}

main() {
    verify_params
    installedPackageVersionId=
    get_latest_package_build
    export_package_version_id "$installedPackageVersionId"
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi

