#!/bin/bash

cd /root
mkdir actions-runner
cd actions-runner
curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

/root/actions-runner/bin/installdependencies.sh

ORGANIZATION=$ORGANIZATION
ACCESS_TOKEN=$ACCESS_TOKEN
REG_TOKEN=$(curl -sX POST -H "Authorization: token ${ACCESS_TOKEN}" https://api.github.com/orgs/${ORGANIZATION}/actions/runners/registration-token | jq .token --raw-output)

CONFIG_OPTS=""
if [[ -n $RUNNER_LABELS ]]; then
    CONFIG_OPTS="${CONFIG_OPTS} --labels ${RUNNER_LABELS}"
fi

./config.sh --url https://github.com/${ORGANIZATION} --token ${REG_TOKEN} ${CONFIG_OPTS}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

exec ./bin/runsvc.sh
