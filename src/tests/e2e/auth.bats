setup() {
    # source script under test
    source ./src/scripts/auth.sh

    export PARAM_JWT_KEY_FILE="MY_CUST_JWT"
    export PARAM_CLIENT_ID="SFDX_CONSUMER_KEY"
    export PARAM_USERNAME="info@lietzau-consulting.de"
    export PARAM_INSTANCE_URL="https://jl-consulting-dev-ed.my.salesforce.com"
    export PARAM_SET_DEFAULT=1
    export MY_CUST_JWT=$(cat .config/MY_JW_TOKEN.txt)
    export SFDX_CONSUMER_KEY=$(cat .config/MY_CONSUMER_KEY.txt)
}

@test "Has valid input for default org > successfully authorizes org" {
    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Setting org as default"* ]]
    [[ $output == *"Authorizing $PARAM_USERNAME at $PARAM_INSTANCE_URL"* ]]
    [[ $output == *"Successfully authorized $PARAM_USERNAME with org"* ]]
}

@test "Has valid input non-default org > successfully authorizes org" {
    # ARRANGE
    export PARAM_SET_DEFAULT=0

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output != *"Setting org as default"* ]]
    [[ $output == *"Authorizing $PARAM_USERNAME at $PARAM_INSTANCE_URL"* ]]
    [[ $output == *"Successfully authorized $PARAM_USERNAME with org"* ]]
}

@test "Valid input without instance url > successfully authorizes org" {
    # ARRANGE
    export PARAM_INSTANCE_URL=

    # ACT
    run main

    # ASSERT
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ $output == *"Setting org as default"* ]]
    [[ $output == *"Authorizing $PARAM_USERNAME at https://login.salesforce.com"* ]]
    [[ $output == *"Successfully authorized $PARAM_USERNAME with org"* ]]
}
