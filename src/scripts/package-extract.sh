#!/bin/bash

# Exit on error
set -e

# Function to check the success of the script steps
function check_success() {
  if [ $? -ne 0 ]; then
    echo "An error occurred. Aborting script."
    exit 1
  fi
}

# Update the repositories
echo "Updating repositories..."
git pull
check_success

# Change directory to the packages
cd "packages/$repoName" || exit
check_success

# Update the master branch
echo "Switching to master branch and updating..."
git checkout master && git pull
check_success

cd ../..

# Extract package name and version aswell as id from sfdx-project.json
echo "Extracting package information from sfdx-project.json..."
sfdx_project_path="packages/$repoName/sfdx-project.json"
packageName=$(jq -r '.packageDirectories[] | select(.path == "src/packaged") | .package' "$sfdx_project_path")
rawVersionName=$(jq -r '.packageDirectories[] | select(.path == "src/packaged") | .versionNumber' "$sfdx_project_path")
packageId=$(jq -r --arg packageName "$packageName" '.packageAliases[$packageName]' "$sfdx_project_path")

# Remove the last 5 characters (".NEXT") from the version
versionName=${rawVersionName::-5}

# Sanity check the extracted data
echo "Package name: $packageName"
echo "Package version: $versionName"
echo "Package ID: $packageId"
