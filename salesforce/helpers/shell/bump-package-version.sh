#! /bin/bash
set -e

bump_package_version() {
    echo "Current version is: $versionNumberLiteral"
    newVersionLiteral=$(make_semver_bump "$PARAM_SEMVER_BUMP" "$versionNumberLiteral")
    echo "New version is: $newVersionLiteral"
}

read_version_from_sfdx_project_file() {
    rawVersionNumberLiteral=$(jq -r '.packageDirectories[] | select(.package == "Orb Developer Demo Package") | .versionNumber' "$1")
    # removes last 5 characters (".NEXT")
    output=${rawVersionNumberLiteral::-5}
    echo "$output"
}

write_new_version_to_sfdx_project() {
    newVersionOutput="$1.NEXT"
    jq --arg a "$newVersionOutput" '(.packageDirectories[] | select(.package == "Orb Developer Demo Package") | .versionNumber) = $a' "$2" > tmp.$$.json && mv tmp.$$.json "$2"
}

make_semver_bump() {
    local -n versionArray
    IFS='.' read -ra versionArray <<< "$2"
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
            echo "Invalid SEMVER tag $0"
            exit 101
            ;;
    esac
}

bump_patch_version() {
    versionArray[2]=$((versionArray[2] + 1))
    join_version_array_to_string versionArray '.'
}

bump_minor_version() {
    versionArray[1]=$((versionArray[1] + 1))
    versionArray[2]=0
    join_version_array_to_string versionArray '.'
}

bump_major_version() {
    versionArray[0]=$((versionArray[0] + 1))
    versionArray[1]=0
    versionArray[2]=0
    join_version_array_to_string versionArray '.'
}

join_version_array_to_string() {
  local -n array=$1
  local joined_string=""
  for element in "${array[@]}"; do
    if [[ -n "$joined_string" ]]; then
      joined_string+="."
    fi
    joined_string+="$element"
  done
  echo "$joined_string"
}

main() {
    if [ -n "$PARAM_PATH" ]; then
        cd "$PARAM_PATH" || exit 1
    fi
    sfdxProjectFileName='sfdx-project.json'
    newVersionLiteral=
    versionNumberLiteral=$(read_version_from_sfdx_project_file $sfdxProjectFileName)
    bump_package_version
    write_new_version_to_sfdx_project "$newVersionLiteral" "$sfdxProjectFileName"
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi
