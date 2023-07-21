#! /bin/bash

verify_params() {
    if [ -z "${!PARAM_PACKAGE_ID}" ]; then
        echo "The environment variable $PARAM_PACKAGE_ID is empty. Provide the package id" >&2
        exit 10
    fi
}

sf_data_query() {
    sf data query --use-tooling-api --json --query "$1" --target-org "$2" 2> /dev/null
}

get_latest_package_build() {
    queryParamValSkipped=
    if [ "${PARAM_RELEASE_CANDIDATE}" -eq 1 ]; then
        echo "Retrieving latest release candidate ..."
        queryParamValSkipped="AND ValidationSkipped = false"
    fi
    queryString="SELECT SubscriberPackageVersionId FROM Package2Version WHERE Package2Id = '${!PARAM_PACKAGE_ID}' $queryParamValSkipped ORDER BY CreatedDate DESC LIMIT 1"
    echo "Query: $queryString"
    subscriberPackageVersionId=$( sf_data_query "$queryString" "${PARAM_DEVHUB_USERNAME}" | jq -r .result.records[0].SubscriberPackageVersionId )
}

export_package_version_id() {
    if [ "$1" = "null" ]; then
        echo "No build found for package. Aborting ..."
        exit 20
    else
        echo "Exporting latest build $1 to $PARAM_PACKAGE_VERSION_EXPORT"
        echo "export $PARAM_PACKAGE_VERSION_EXPORT=$1" >> "$BASH_ENV"
    fi
}

main() {
    verify_params
    subscriberPackageVersionId=
    get_latest_package_build
    export_package_version_id "$subscriberPackageVersionId"
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi

