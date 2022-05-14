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

```bash
bats src/tests/unit
```

Be careful with E2E tests, because they consume API limits (test execution, package builds, scratch org setups).
