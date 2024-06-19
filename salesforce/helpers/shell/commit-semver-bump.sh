#! /bin/bash
set -e

set_git_config() {
    git config --global user.name "CircleCI Runner"
    git config --global user.email info@lietzau-consulting.de
}

commit_sfdx_project() {
    git add sfdx-project.json
    git commit -m "ops [skip ci]: semver bump for orb build"
}

push_to_remote() {
    git push -q "https://${DEMO_PACKAGE_REPO_TOKEN}@github.com/j-schreiber/circleci-orb-demo-package.git"
}

main() {
    if [ -n "$PARAM_PATH" ]; then
        cd "$PARAM_PATH" || exit 1
    fi
    set_git_config
    commit_sfdx_project
    push_to_remote
}

ORB_TEST_ENV="bats-core"
if [ "${0#*"$ORB_TEST_ENV"}" == "$0" ]; then
    main
fi
