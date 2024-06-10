Welcome to the official repository of the [jsc/salesforce](https://circleci.com/developer/orbs/orb/jsc/salesforce) orb.

# Prerequisites

You need the following tools installed on your dev machine (host system) to get started

- **Docker & Docker-Compose**: The docker container is your local dev environment. This is where you install and test various CLI installations and configurations. It uses the same image that is also used by CircleCI and has all important dependencies (like `jq` or `java`) installed: `cimg/openjdk:17.0-node`. The docker container for dev comes with `bats` installed. Follow instructions to install docker here: [business-apps-developer-setup](https://github.com/mobilityhouse/tmh-business-it-developer-setup/tree/main/macOS/salesforce).
- **Local SF(DX) CLI**: You will not use this installation during orb authoring process, but it may be helpful to write and understand commands against your authenticated orgs like Staging, Production, etc.
- **CircleCI CLI**: Generate access tokens, locally validate and pack orbs, validate configs and command ymls during orb authoring.

# Setup Dev Environment

## Local Environment Bootstrapping

First, clone this repository locally. Then, initialise and checkout the `demo-package` submodule that contains an SFDX project. The project is used for testing all scratch org and packaging commands.

```bash
git submodule update --init --recursive
git submodule foreach --recursive git checkout master
```

For local development, build and use the supplied docker image.

```bash
# Open the "docker hub", this will automatically start the background daemon
open -a Docker

# check if deamon is running
docker info

# launch the local dev environment
docker compose up -d && docker compose exec orbdeveloper bash
```

The image does not include the SF CLI. So most unit tests and most e2es will fail. Follow instructions
in the next section to finalize setup of your local dev environment.

## Finalise Local Environment

To proceed with local development, you need to install the SF CLI and Plugins in your docker container. This step is optional and may interfere with some E2E tests.
The easiest way is using the bash script from the orb command. It automatically installs the latest version.

```bash
# export SALESFORCE_CLI_VERSION=2.0.2-3bd4327
# export SALESFORCE_CLI_VERSION=2.40.7-bde121f
bash src/scripts/install-cli.sh

# install packaging plugin, if it is not installed, the jq command gets an error, because the plugin will be automatically installed
# and the json output won't be a compatible json format
sf plugins install @salesforce/plugin-packaging
```

## Development

We recommend to use your host machine (authenticated orgs and SF CLI installation) to experiment with new commands.

### Directory Structure

- [src](src) - Entire source code of the orb
  - [commands](src/commands) - Command definitions
  - [examples](src/examples) - Example usage of commands and jobs
  - [jobs](src/jobs) - Multiple commands chained together, exposed as a "standalone" job
  - [scripts](src/scripts) - Shell scripts that are used by commands
  - [tests](src/tests) - Bats tests for shell scripts
- [salesforce](salesforce) - Submodule with Salesforce example package

### Pack & Publish Pipeline

This repository uses the "Orb Development Kit" [CircleCI recommendations](https://circleci.com/docs/orb-author/#orb-development-kit) to automatically pack & publish new orb versions.

1. Checkout new branch (e.g. JIRA ticket number, `feature/SAL-1234`)
2. Commit changes according to our guidelines (`feat: did this and that`)
3. When development is done, open PR and use `semver` tag in title
   - `[semver:patch]`: Creates a new **patch** version
   - `[semver:minor]`: Creates a new **minor** version
   - `[semver:major]`: Creates a new **major** version
4. Squash merge the PR (so the new commit uses the PR title 1:1)

# Testing

This orb uses BATS to test bash scripts. For now, the pipeline does not run bats tests, only full integration tests. Run the tests from the root directory of the orb repository, not the demo project.

To run some of the unit tests, you need to be authenticated with your personal developer edition (DevHub must be enabled; Connected App for integration must be configured).

The easiest way to do that, is to run the auth command that is supplied by the orb. The command is self-documenting and also documented in its [tests](src/tests/e2e/auth.bats)

```bash
# modify exports.env to your liking and create jwt.txt and consumer_key.txt
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

# Troubleshooting

## Cannot load metadata for docker.io/cimg/openjdk:17.0-node

Docker cannot load the CircleCI image. Detailed error message looks like this

```bash
failed to solve: cimg/openjdk:17.0-node: failed to resolve source metadata for docker.io/cimg/openjdk:17.0-node: failed to authorize: failed to fetch oauth token: unexpected status from GET request to https://auth.docker.io/token?scope=repository%3Acimg%2Fopenjdk%3Apull&service=registry.docker.io: 401 Unauthorized
```

:white_check_mark: This issue happened, when we were signed into DockerHub with a newly created account. **Signing out** and using docker without a user solved the issue.

# rosetta error: failed to open elf at /lib64/ld-linux-x86-64.so.2

After installing sf cli (latest version or explicit version), it cannot be launched. The error message looks like this

```bash
$ root@a720c96cf782:/home/circleci/project# sf
rosetta error: failed to open elf at /lib64/ld-linux-x86-64.so.2
/usr/bin/sf: line 45:    77 Trace/breakpoint trap   "$NODE" "$DIR/run" "$@"
```

:white_check_mark: Issue appears to be related to Macbook M1 / ARM architecture. Adding the platform `linux/amd64` to [docker-compose.yml](docker-compose.yml) solved it.
