#! /bin/bash

verify_params() {
    if [ -z "${PARAM_PACKAGE}" ]; then
        echo "No environment variable for package set. Set the name of the environment variable when calling the command." >&2
        exit 10
    fi
    if [ -z "${!PARAM_PACKAGE}" ]; then
        echo "The variable ${PARAM_PACKAGE} is empty. Please configure the package id (0Ho) or the package alias in sfdx-project.json." >&2
        exit 11
    fi
    if [ -n "$PARAM_REQUIRE_KEY" ] && [ "$PARAM_REQUIRE_KEY" -eq 0 ]; then
        echo "No installation key required. Skipping installation key validation." >&2
    else
        if [ -z "${PARAM_INSTALLATION_KEY}" ]; then
            echo "No environment variable for installation key set. Set the name of the environment variable when calling the command." >&2
            exit 12
        fi
        if [ -z "${!PARAM_INSTALLATION_KEY}" ]; then
            echo "The variable ${PARAM_INSTALLATION_KEY} is empty. Please configure the installation key that is used to secure the package version." >&2
            exit 13
        fi
    fi
}

sf_package_version_create() {
    sf package version create "$@"
}

export_package_version_id() {
    if [ -n "$PARAM_PACKAGE_VERSION_EXPORT" ]; then
        echo "Exporting new package version $1 to $PARAM_PACKAGE_VERSION_EXPORT"
        echo "export $PARAM_PACKAGE_VERSION_EXPORT=$1" >> "$BASH_ENV"
    fi
}

build_package() {
    params=()
    params+=(--package "${!PARAM_PACKAGE}")
    params+=( --wait 60)
    params+=( --json)
    if [ "$PARAM_REQUIRE_KEY" = true ] || [ "$PARAM_REQUIRE_KEY" -eq 1 ]; then
        params+=( --installation-key "${!PARAM_INSTALLATION_KEY}")
    else
        params+=( --installation-key-bypass)
    fi
    if [ "$PARAM_IS_RELEASE_CANDIDATE" = true ] || [ "$PARAM_IS_RELEASE_CANDIDATE" -eq 1 ]; then
        params+=( --code-coverage)
    else
        params+=( --skip-validation)
    fi
    if [ -n "$PARAM_DEV_HUB" ]; then
        params+=( --target-dev-hub "$PARAM_DEV_HUB")
    fi
    echo "sf package version create ${params[*]}"
    sf_package_version_create "${params[@]}" | tee package_version_create_result.json || true
}

process_build_result() {
    commandStatus=$( jq -r .status package_version_create_result.json )
    if [ "$commandStatus" -eq 0 ]; then
        packageVersionId=$( jq -r .result.SubscriberPackageVersionId package_version_create_result.json )
        if [ "$packageVersionId" != "null" ]; then
            echo "Successfully created new package version: $packageVersionId"
            export_package_version_id "$packageVersionId"
            exit 0
        else
            buildStatus=$( jq -r .result.Status package_version_create_result.json )
            echo "Package build timed out with status: $buildStatus"
            if [ -n "$PARAM_PACKAGE_VERSION_EXPORT" ]; then
                echo "Export specified but no package version created. Exit with 101"
                exit 101
            fi
        fi
    else
        buildError=$( jq -r .message package_version_create_result.json )
        echo "Package build failed with message: $buildError"
        exit 100
    fi
}

main() {
    if [ -n "$PARAM_PATH" ]; then
        cd "$PARAM_PATH" || exit 1
    fi
    verify_params
    build_package
    process_build_result
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi
