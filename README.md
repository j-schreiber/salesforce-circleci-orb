Welcome to the official repository of the [jsc/salesforce](https://circleci.com/developer/orbs/orb/jsc/salesforce) orb.

# Setup Dev Environment

First, checkout the `demo-package` submodule that contains an SFDX project. The project is used for testing all scratch org and packaging commands.

```bash
git submodule update --init --recursive
git submodule foreach --recursive git checkout master
```

For local development, build and use the supplied docker image.

```bash
docker-compose up -d && docker-compose exec orbdeveloper bash
```

The image does not include the CLI version. So all unit tests and most e2es will fail. Follow instructions
in section Testing to finalize setup of your local dev environment.

# Testing

The easiest way to install the CLI is using the bash script from the orb command. It automatically installs the latest version.

```bash
# export SFDX_CLI_VERSION=2.0.2-3bd4327
# export SFDX_CLI_VERSION=2.1.1-1718d40
bash src/scripts/install-cli.sh

# install packaging plugin, if it is not installed, the jq command gets an error, because the plugin will be automatically installed
# and the json output won't be a compatible json format
sf plugins install @salesforce/plugin-packaging
```

This orb uses BATS to test bash scripts. For now, the pipeline does not run bats tests, only full integration tests. Run the tests from the root directory of the orb repository, not the demo project.

To run some of the unit tests, you need to be authenticated with your personal developer edition (DevHub must be enabled; Connected App for integration must be configured).

The easiest way to do that, is to run the auth command that is supplied by the orb. The command is self-documenting and also documented in its [tests](src/tests/e2e/auth.bats)

```bash
# modify exports.env to your liking to and create jwt.txt and consumer_key.txt
set -o allexport
source .config/exports.env
set +o allexport
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
