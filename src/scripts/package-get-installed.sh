#! /bin/bash

verify_params() {
    if [ -z "${PARAM_PACKAGE_ID}" ] || [ -z "${!PARAM_PACKAGE_ID}" ]; then
        echo "No environment variable for package set or the environment variable ${PARAM_PACKAGE_ID} is empty. Provide a valid package version (0Ho) for this command." >&2
        exit 10
    fi
}

query_subscriber_package_id() {
    sf data query --use-tooling-api --json \
        --query "SELECT SubscriberPackageId FROM Package2 WHERE Id = '${!PARAM_PACKAGE_ID}' LIMIT 1" \
        --target-org "$PARAM_DEVHUB_USERNAME" \
        2> /dev/null
}

query_installed_package_version_id() {
    sf data query --use-tooling-api --json \
        --query "SELECT SubscriberPackageVersionId FROM InstalledSubscriberPackage WHERE SubscriberPackageId = '$1' LIMIT 1" \
        --target-org "$PARAM_TARGET_ORG" \
        2> /dev/null
}

get_subscriber_package_id() {
    subscriberPackageId=$( query_subscriber_package_id | jq -r .result.records[0].SubscriberPackageId )
    echo "$subscriberPackageId"
}

get_installed_package_version_id() {
    installedPackageVersionId=$( query_installed_package_version_id "$1" | jq -r .result.records[0].SubscriberPackageVersionId )
    echo "$installedPackageVersionId"
}

export_package_version_id() {
    if [ "$1" = "null" ]; then
        echo "No installed package version found on $PARAM_TARGET_ORG. Nothing exported."
    else
        echo "Exporting installed package version $1 to $PARAM_PACKAGE_VERSION_EXPORT"
        echo "export $PARAM_PACKAGE_VERSION_EXPORT=$1" >> "$BASH_ENV"
    fi
}

main() {
    verify_params
    subscriberPackageId=$( get_subscriber_package_id )
    if [ "$subscriberPackageId" != "null" ]; then
        echo "Subscriber Package Id for ${!PARAM_PACKAGE_ID}: $subscriberPackageId"
        installedPackageVersionId=$( get_installed_package_version_id "$subscriberPackageId" )
        export_package_version_id "$installedPackageVersionId"
    else
        echo "No Subscriber Package Id found. Nothing exported."
    fi
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi
