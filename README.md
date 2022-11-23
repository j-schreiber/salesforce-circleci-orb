Welcome to the official repository of the [jsc/salesforce](https://circleci.com/developer/orbs/orb/jsc/salesforce) orb.

# Setup Dev Environment

First, checkout the `demo-package` submodule, that contains an SFDX project. The project is used for testing all scratch org and packaging commands.

```bash
git submodule update --init --recursive
git submodule foreach --recursive git checkout master
```

The orb may install tools (such as the SFDX CLI). It makes sense to test and develop it in a container. Execute from the orb project root, not the demo-package.

```bash
docker run --name salesforce-orb-dev-env -it --mount type=bind,source="$(pwd)",target=/home/circleci/project cimg/base:stable
```

Install Bats & SFDX CLI in local dev container

```bash
mkdir ~/tmp && cd ~/tmp && git clone https://github.com/bats-core/bats-core.git && sudo bats-core/install.sh /usr/local && cd ~/project
bash src/scripts/install-cli.sh
```

# Testing

This orb uses BATS to test bash scripts. For now, the pipeline does not run bats tests, only full integration tests. Run the tests from the root directory of the orb repository, not the demo project.

To run some of the unit tests, you need to be authenticated with the orb development org, `info@lietzau-consulting.de`. The easiest way to do that, is to run the auth command that is supplied by the orb. The command is self-documenting and also documented in its [tests](src/tests/e2e/auth.bats)

```bash
# this assumes, that you have stored all sensitive data in text files in .config
export PARAM_JWT_KEY_FILE="SFDX_JWT_KEY"
export PARAM_CLIENT_ID="SFDX_CONSUMER_KEY"
export PARAM_USERNAME="info@lietzau-consulting.de"
export PARAM_INSTANCE_URL="https://jl-consulting-dev-ed.my.salesforce.com"
export PARAM_SET_DEFAULT=1
export SFDX_JWT_KEY=$(cat .config/MY_JW_TOKEN.txt)
export SFDX_CONSUMER_KEY=$(cat .config/MY_CONSUMER_KEY.txt)
bash src/scripts/auth.sh
```

After authentication, you can safely run unit tests:

```bash
bats src/tests/unit
```

Be careful with E2E tests, because they consume API limits (test execution, package builds, scratch org setups).

```bash
bats src/tests/e2e
```
