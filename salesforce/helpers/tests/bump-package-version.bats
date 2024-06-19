setup() {
    # source script under test
    source salesforce/helpers/shell/bump-package-version.sh

    # mock environment variables
    export PARAM_PATH="salesforce/demo-package"
}

teardown() {
    cd $PARAM_PATH
    git checkout sfdx-project.json
}

@test "Bump package PATCH version > commits with PATCH bumped" {
    # Arrange
    export PARAM_SEMVER_BUMP="PATCH"

    # Act
    run main

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Current version is: 0.1.1"* ]]
    [[ "$output" == *"New version is: 0.1.2"* ]]
    newVersionOutput=$(jq -r '.packageDirectories[] | select(.package == "Orb Developer Demo Package") | .versionNumber' "$PARAM_PATH"/sfdx-project.json)
    [ "$newVersionOutput" == "0.1.2.NEXT" ]
}

@test "Bump package MINOR version > commits with MINOR bumped" {
    # Arrange
    export PARAM_SEMVER_BUMP="MINOR"

    # Act
    run main

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Current version is: 0.1.1"* ]]
    [[ "$output" == *"New version is: 0.2.0"* ]]
    newVersionOutput=$(jq -r '.packageDirectories[] | select(.package == "Orb Developer Demo Package") | .versionNumber' "$PARAM_PATH"/sfdx-project.json)
    [ "$newVersionOutput" == "0.2.0.NEXT" ]
}

@test "Bump package MAJOR version > commits with MAJOR bumped" {
    # Arrange
    export PARAM_SEMVER_BUMP="MAJOR"

    # Act
    run main

    # Assert
    echo "Actual output"
    echo "$output"
    echo "Actual status: $status"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Current version is: 0.1.1"* ]]
    [[ "$output" == *"New version is: 1.0.0"* ]]
    newVersionOutput=$(jq -r '.packageDirectories[] | select(.package == "Orb Developer Demo Package") | .versionNumber' "$PARAM_PATH"/sfdx-project.json)
    [ "$newVersionOutput" == "1.0.0.NEXT" ]
}
