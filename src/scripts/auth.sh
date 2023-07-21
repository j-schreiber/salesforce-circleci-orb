#! /bin/bash
set -e

verify_params() {
    if [ -z "${PARAM_JWT_KEY_FILE}" ]; then
        echo "The JWT key is required. Please ensure the <<parameters.jwtKey>> env var has been set correctly or use the default value: SFDX_JWT_KEY."
        exit 1
    fi
    if [ -z "${!PARAM_JWT_KEY_FILE}" ]; then
        echo "The variable ${PARAM_JWT_KEY_FILE} is empty. Please store a valid base64 encoded JWT-key file"
        exit 1
    fi
    if [ -z "${PARAM_CLIENT_ID}" ]; then
        echo "A consumer key is required. Please ensure the <<parameters.consumerKey>> env var has been set correctly or use the default value: SFDX_CONSUMER_KEY"
        exit 1
    fi
    if [ -z "${!PARAM_CLIENT_ID}" ]; then
        echo "The variable ${PARAM_CLIENT_ID} is empty. Please store a valid consumer key for the connected app."
        exit 1
    fi
    if [ -z "$PARAM_USERNAME" ]; then
        echo "Username is empty. Set a username that is pre-authorized with the connected app"
        exit 1
    fi
}

decrypt_key() {
    echo "${!PARAM_JWT_KEY_FILE}" | base64 --decode --ignore-garbage > ./server.key
}

sf_org_login_jwt() {
    sf org login jwt "$@"
}

authenticate_org() {
    if [[ -z "$PARAM_INSTANCE_URL" ]]; then
        export PARAM_INSTANCE_URL=https://login.salesforce.com
    fi
    echo "Authorizing $PARAM_USERNAME at $PARAM_INSTANCE_URL ..."
    params=()
    params+=(--client-id "${!PARAM_CLIENT_ID}")
    params+=( --jwt-key-file server.key)
    params+=( --username "$PARAM_USERNAME")
    params+=( --instance-url "$PARAM_INSTANCE_URL")
    if [ "$PARAM_SET_DEFAULT" = true ] || [ "$PARAM_SET_DEFAULT" -eq 1 ]; then
        echo "Setting org as default devhub ..."
        params+=( --set-default-dev-hub)
    fi
    sf_org_login_jwt "${params[@]}"
}

main() {
    verify_params
    decrypt_key
    authenticate_org
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi
