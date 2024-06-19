setup() {
    # source script under test
    source salesforce/helpers/shell/commit-semver-bump.sh

    # mock environment variables
    export PARAM_PATH="salesforce/demo-package"

    # mock changes to sfdx-project.json
    cat salesforce/helpers/data/mock-sfdx-project.json > salesforce/demo-package/sfdx-project.json
}

teardown() {
    cd $PARAM_PATH
    git reset HEAD~1
    git checkout sfdx-project.json
}

@test "basic execute > commits with skip ci" {
    # Arrange
    function push_to_remote() {
        echo "git push"
    }

    # Act
    run main

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" == *"git push"* ]]
    [[ "$output" == *"ops [skip ci]: semver bump for orb build"* ]]
    [[ "$output" == *"1 file changed"* ]]
}
