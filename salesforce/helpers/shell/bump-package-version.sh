#! /bin/bash
set -e

read_version_from_sfdx_project_file() {
    rawVersionNumberLiteral=$(jq -r '.packageDirectories[] | select(.path == "src/packaged") | .versionNumber' "$1")
    # removes last 5 characters (".NEXT")
    versionNumberLiteral=${rawVersionNumberLiteral::-5}
    echo "Current version is: $versionNumberLiteral"
    # splits to versionArray for processing
    IFS='.' read -ra versionArray <<< "$versionNumberLiteral"
}

write_new_version_to_sfdx_project() {
    echo "New version is: $1"
    newVersionOutput="$1.NEXT"
    jq --arg a "$newVersionOutput" '(.packageDirectories[] | select(.path == "src/packaged") | .versionNumber) = $a' "$2" > tmp.$$.json && mv tmp.$$.json "$2"
}

make_semver_bump() {
    case "$1" in
        "PATCH")
            bump_patch_version
            ;;
        "MINOR")
            bump_minor_version
            ;;
        "MAJOR")
            bump_major_version
            ;;
        *)
            echo "Invalid SEMVER tag $1"
            exit 100
            ;;
    esac
}

bump_patch_version() {
    echo "Applying PATCH increment"
    versionArray[2]=$((versionArray[2] + 1))
    join_version_array_to_string versionArray '.'
}

bump_minor_version() {
    echo "Applying MINOR increment"
    versionArray[1]=$((versionArray[1] + 1))
    versionArray[2]=0
    join_version_array_to_string versionArray '.'
}

bump_major_version() {
    echo "Applying MAJOR increment"
    versionArray[0]=$((versionArray[0] + 1))
    versionArray[1]=0
    versionArray[2]=0
    join_version_array_to_string versionArray '.'
}

join_version_array_to_string() {
  local -n array=$1
  for element in "${array[@]}"; do
    if [[ -n "$newVersionLiteral" ]]; then
      newVersionLiteral+="."
    fi
    newVersionLiteral+="$element"
  done
}

main() {
    if [ -n "$PARAM_PATH" ]; then
        cd "$PARAM_PATH" || exit 1
    fi
    sfdxProjectFileName='sfdx-project.json'
    newVersionLiteral=
    versionArray=()
    versionNumberLiteral=
    read_version_from_sfdx_project_file $sfdxProjectFileName
    make_semver_bump "$PARAM_SEMVER_BUMP" "$versionNumberLiteral"
    write_new_version_to_sfdx_project "$newVersionLiteral" "$sfdxProjectFileName"
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi
