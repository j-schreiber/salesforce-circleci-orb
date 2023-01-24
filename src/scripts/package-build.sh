#! /bin/bash

PACKAGE_BUILD_LOG=/tmp/package-build-log.txt

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

build_package_with_parameters() {
    echo "sfdx force:package:version:create $*"
    sfdx force:package:version:create "$@"
}

export_package_version_id() {
    echo "Exporting new package version $1 to $PARAM_PACKAGE_VERSION_EXPORT"
    echo "export $PARAM_PACKAGE_VERSION_EXPORT=$1" >> "$BASH_ENV"
}

build_package() {
    params=()
    params+=(--package "${!PARAM_PACKAGE}")
    params+=( --wait 60)
    if [ "$PARAM_REQUIRE_KEY" = true ] || [ "$PARAM_REQUIRE_KEY" -eq 1 ]; then
        params+=( --installationkey "${!PARAM_INSTALLATION_KEY}")
    else
        params+=( --installationkeybypass)
    fi
    if [ "$PARAM_IS_RELEASE_CANDIDATE" = true ] || [ "$PARAM_IS_RELEASE_CANDIDATE" -eq 1 ]; then
        params+=( --codecoverage)
    else
        params+=( --skipvalidation)
    fi
    if [ -n "$PARAM_DEV_HUB" ]; then
        params+=( --targetdevhubusername "$PARAM_DEV_HUB")
    fi
    build_package_with_parameters "${params[@]}"
}

main() {
    if [ -n "$PARAM_PATH" ]; then
        cd "$PARAM_PATH" || exit 1
    fi
    verify_params
    build_package | tee $PACKAGE_BUILD_LOG
    packageVersionLine=$( grep -w "Subscriber Package Version Id:" $PACKAGE_BUILD_LOG )
    [[ $packageVersionLine =~ (04t[a-zA-Z0-9]{15}) ]] && createdPackageVersion="${BASH_REMATCH[1]}"
    rm -f $PACKAGE_BUILD_LOG
    if [ -z "$createdPackageVersion" ]; then
        echo "sfdx force:package:version:create did not create a package version. Aborting ..." >&2
        exit 100
    fi
    if [ -n "$PARAM_PACKAGE_VERSION_EXPORT" ]; then
        export_package_version_id "$createdPackageVersion"
    fi
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi
