#! /bin/bash

verify_params() {
    if [ -z "${PARAM_TARGET_ORG}" ]; then
        echo "No target org specified. Please set the target org where the package will be installed."
        exit 10
    fi
    if [ -z "${!PARAM_PACKAGE_VERSION}" ] && [ -z "${!PARAM_PACKAGE_ID}" ]; then
        echo "Both package version and package id are empty. Provide an environment variable for either package version or package." >&2
        exit 11
    fi
    if [ "$PARAM_QUERY_LATEST_BUILD" -eq 1 ] && [ -z "${!PARAM_PACKAGE_ID}" ]; then
        echo "Command is set to query latest build, but no package id specified. Provide the package id and the devhub user name (not the target org)" >&2
        exit 12
    fi
    if [ "$PARAM_QUERY_LATEST_BUILD" -eq 1 ] && [ -z "${PARAM_DEVHUB_USERNAME}" ]; then
        echo "Command is set to query latest build, but no devhub username is specified. Provide the devhub username (not the target org) and the package id." >&2
        exit 13
    fi
    if [ "$PARAM_QUERY_LATEST_BUILD" -eq 0 ] && [ -z "${!PARAM_PACKAGE_VERSION}" ]; then
        echo "Command is set use a package version, but no package version was provided. Set packageVersion parameter with an environment variable name." >&2
        exit 14
    fi
}

query_latest_package_build() {
    queryParamValSkipped=
    queryString="SELECT SubscriberPackageVersionId FROM Package2Version WHERE Package2Id = '${!PARAM_PACKAGE_ID}' $queryParamValSkipped ORDER BY CreatedDate DESC LIMIT 1"
    if [ "$1" == "true" ]; then
        queryParamValSkipped="AND ValidationSkipped = false"
    fi
    # query the latest package version or the latest release candidate and output as csv
    sfdx force:data:soql:query -t -q "$queryString" -u "${PARAM_DEVHUB_USERNAME}" -r csv | sed "1 d"
}

get_package_version_id() {
    if [ "${PARAM_QUERY_LATEST_BUILD}" -eq 0 ]; then
        echo "Package version set. Using ${!PARAM_PACKAGE_VERSION} ..."
        packageVersionId="${!PARAM_PACKAGE_VERSION}"
    else
        if [ "$PARAM_INSTALL_RELEASE_CANDIDATE" -eq 1 ]; then
            echo "No package version set. Finding latest release candidate for ${!PARAM_PACKAGE_ID} ..."
            packageVersionId=$( query_latest_package_build "true" )
        else
            echo "No package version set. Finding latest package version for ${!PARAM_PACKAGE_ID} ..."
            packageVersionId=$( query_latest_package_build "false" )
        fi
    fi
}

install_package_with_params() {
    echo "sfdx force:package:install $*"
    sfdx force:package:install "$@"
}

install_package() {
    if [ -z "$packageVersionId" ]; then
        echo "No valid package version retrieved. Exiting ..." >&2
        exit 20
    fi
    echo "Installing $packageVersionId on $PARAM_TARGET_ORG ..."
    params=()
    params+=(--package "$packageVersionId")
    params+=( --targetusername "$PARAM_TARGET_ORG")
    params+=( --noprompt)
    params+=( --wait 10)
    params+=( --publishwait 10)
    if [ -n "${!PARAM_INSTALLATION_KEY}" ]; then
        params+=( --installationkey "${!PARAM_INSTALLATION_KEY}")
    fi
    install_package_with_params "${params[@]}"
}

main() {
    verify_params
    get_package_version_id
    install_package
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi

