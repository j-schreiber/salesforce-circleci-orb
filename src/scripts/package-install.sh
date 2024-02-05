#! /bin/bash

verify_params() {
    if [ -z "$PARAM_IS_ROLLBACK" ]; then
        export PARAM_IS_ROLLBACK=0
    fi
    if [ -z "${PARAM_TARGET_ORG}" ]; then
        echo "No target org specified. Please set the target org where the package will be installed."
        exit 10
    fi
    if [ "$PARAM_IS_ROLLBACK" -eq 0 ] && [ -z "${!PARAM_PACKAGE_VERSION}" ] && [ -z "${!PARAM_PACKAGE_ID}" ]; then
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
    if [ "$PARAM_IS_ROLLBACK" -eq 0 ] && [ "$PARAM_QUERY_LATEST_BUILD" -eq 0 ] && [ -z "${!PARAM_PACKAGE_VERSION}" ]; then
        echo "Command is set use a package version, but no package version was provided. Set packageVersion parameter with an environment variable name." >&2
        exit 14
    fi
}

sf_data_query() {
    sf data query --use-tooling-api --json --query "$1" --target-org "$2" 2> /dev/null
}

get_latest_package_build() {
    queryParamValSkipped=
    if [ "$1" == "true" ]; then
        queryParamValSkipped="AND ValidationSkipped = false"
    fi
    queryString="SELECT SubscriberPackageVersionId FROM Package2Version WHERE Package2Id = '${!PARAM_PACKAGE_ID}' $queryParamValSkipped ORDER BY CreatedDate DESC LIMIT 1"
    packageVersionId=$( sf_data_query "$queryString" "${PARAM_DEVHUB_USERNAME}" | jq -r .result.records[0].SubscriberPackageVersionId )
    if [ "$packageVersionId" = "null" ]; then
        packageVersionId=
    fi
}

get_package_version_id() {
    if [ "${PARAM_QUERY_LATEST_BUILD}" -eq 0 ]; then
        echo "Package version set. Using ${!PARAM_PACKAGE_VERSION} ..."
        packageVersionId="${!PARAM_PACKAGE_VERSION}"
    else
        if [ "$PARAM_INSTALL_RELEASE_CANDIDATE" -eq 1 ]; then
            echo "No package version set. Finding latest release candidate for ${!PARAM_PACKAGE_ID} ..."
            get_latest_package_build "true"
        else
            echo "No package version set. Finding latest package version for ${!PARAM_PACKAGE_ID} ..."
            get_latest_package_build "false"
        fi
    fi
}

install_package_with_params() {
    sf package install "$@"
}

install_package() {
    if [ -z "$packageVersionId" ]; then
        if [ "$PARAM_IS_ROLLBACK" -eq 0 ]; then
            echo "No valid package version retrieved. Exiting ..." >&2
            exit 20
        fi
        if [ "$PARAM_IS_ROLLBACK" -eq 1 ]; then
            echo "Running in rollback mode but found no package version. Skipping ..."
            exit 0
        fi
    fi
    echo "Installing $packageVersionId on $PARAM_TARGET_ORG ..."
    params=()
    params+=(--json)
    params+=( --package "$packageVersionId")
    params+=( --target-org "$PARAM_TARGET_ORG")
    params+=( --no-prompt)
    params+=( --wait 10)
    params+=( --publish-wait 10)
    if [ -n "${!PARAM_INSTALLATION_KEY}" ]; then
        params+=( --installation-key "${!PARAM_INSTALLATION_KEY}")
    fi
    echo "sf package install ${params[*]}"
    install_package_with_params "${params[@]}" | tee package_version_install_result.json || true
}

process_install_result() {
    commandStatus=$( jq -r .status package_version_install_result.json )
    if [ "$commandStatus" -eq 0 ]; then
        resultStatus=$( jq -r .result.Status package_version_install_result.json )
        if [ "$resultStatus" == "SUCCESS" ]; then
            echo "Successfully installed package [$packageVersionId]"
        else
            echo "Package install timed out with status: $resultStatus"
            exit 101
        fi
    else
        installError=$( jq -r .message package_version_install_result.json )
        echo "Package install failed with message: $installError"
        exit 100
    fi
}

deploy_post_install_metadata() {
    if [ -n "$PARAM_PROJECT_PATH" ]; then
        cd "$PARAM_PROJECT_PATH" || exit 1
    fi
    if [ -n "$PARAM_POST_INSTALL_SOURCE_PATH" ]; then
        deploy_params=()
        deploy_params+=(--source-dir)
        IFS=" " read -r -a paths <<< "$PARAM_POST_INSTALL_SOURCE_PATH"
        for path in "${paths[@]}"
        do
            deploy_params+=( "$path")
        done
        deploy_params+=( --target-org "$PARAM_TARGET_ORG")
        deploy_params+=( --wait 10)
        deploy_params+=( --test-level RunLocalTests)
        deploy_params+=( --verbose)
        sf_project_deploy_start "${deploy_params[@]}"
    fi
}

sf_project_deploy_start() {
    echo "sf project deploy start $*"
    sf project deploy start "$@"
}

main() {
    verify_params
    get_package_version_id
    install_package
    process_install_result
    deploy_post_install_metadata
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi

