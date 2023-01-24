#! /bin/bash

verify_params() {
    if [ -z "${PARAM_PACKAGE_ID}" ] || [ -z "${!PARAM_PACKAGE_ID}" ]; then
        echo "No environment variable for package set or the environment variable ${PARAM_PACKAGE_ID} is empty. Provide a valid package version (0Ho) for this command." >&2
        exit 10
    fi
}

get_subscriber_package_id() {
    queryString="SELECT SubscriberPackageId FROM Package2 WHERE Id = '${!PARAM_PACKAGE_ID}' LIMIT 1"
    subscriberPackageId=$( sfdx force:data:soql:query --use-tooling-api --query "$queryString" --target-org "$PARAM_DEVHUB_USERNAME" --result-format csv | sed "1 d" )
    echo "$subscriberPackageId"
}

get_installed_package_version_id() {
    queryString="SELECT SubscriberPackageVersionId FROM InstalledSubscriberPackage WHERE SubscriberPackageId = '$1' LIMIT 1"
    installedPackageVersionId=$( sfdx force:data:soql:query --use-tooling-api --query "$queryString" --target-org "$PARAM_TARGET_ORG" --result-format csv | sed "1 d" )
    echo "$installedPackageVersionId"
}

export_package_version_id() {
    if [ -z "$1" ]; then
        echo "No installed package version found on org. Nothing exported."
    else
        echo "Exporting installed package version $1 to $PARAM_PACKAGE_VERSION_EXPORT"
        echo "export $PARAM_PACKAGE_VERSION_EXPORT=$1" >> "$BASH_ENV"
    fi
}

main() {
    verify_params
    subscriberPackageId=$( get_subscriber_package_id )
    echo "Found subscriber package id for ${!PARAM_PACKAGE_ID}: $subscriberPackageId"
    installedPackageVersionId=$( get_installed_package_version_id "$subscriberPackageId" )
    export_package_version_id "$installedPackageVersionId"
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi
