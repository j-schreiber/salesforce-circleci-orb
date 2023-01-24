Welcome to the official repository of the [jsc/salesforce](https://circleci.com/developer/orbs/orb/jsc/salesforce) orb.

# Setup Dev Environment

First, checkout the `demo-package` submodule that contains an SFDX project. The project is used for testing all scratch org and packaging commands.

```bash
git submodule update --init --recursive
git submodule foreach --recursive git checkout master
```

For local development, build and use the supplied docker image. The CLI is not pre-authenticated, so some unit tests and most e2es will fail. Follow instructions
in section Testing to finalize setup of your local dev environment.

```bash
docker-compose up -d && docker-compose exec orbdeveloper bash
```

# Testing

This orb uses BATS to test bash scripts. For now, the pipeline does not run bats tests, only full integration tests. Run the tests from the root directory of the orb repository, not the demo project.

To run some of the unit tests, you need to be authenticated with your personal developer edition (DevHub must be enabled; Connected App for integration must be configured).

The easiest way to do that, is to run the auth command that is supplied by the orb. The command is self-documenting and also documented in its [tests](src/tests/e2e/auth.bats)

```bash
# this assumes, that you have stored all sensitive data in text files in .config
export PARAM_JWT_KEY_FILE="SFDX_JWT_KEY"
export PARAM_CLIENT_ID="SFDX_CONSUMER_KEY"
export PARAM_USERNAME="your-username@your-domain.com"
export PARAM_INSTANCE_URL="https://your-domain.my.salesforce.com"
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
