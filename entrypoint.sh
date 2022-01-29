#!/bin/bash

set -e

if [[ -z ${RUNNER_TOKEN} ]];
then
    echo "Environment variable 'RUNNER_TOKEN' is not set"
    exit 1
fi

if [[ -z ${REPOSITORY_URL} ]];
then
    echo "Environment variable 'REPOSITORY_URL' is not set"
    exit 1
fi


export RUNNER_ALLOW_RUNASROOT=1
export PATH=$PATH:/actions-runner

# print runner version
echo "github runner version: $(./config.sh --version)"
echo "github runner commit: $(./config.sh --commit)"

_RUNNER_NAME=${RUNNER_NAME:-${RUNNER_NAME_PREFIX:-github-runner}-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')}
_RUNNER_WORKDIR=${RUNNER_WORKDIR:-/_work}
_LABELS=${RUNNER_LABELS:-default}

configure_runner() {
    /actions-runner/config.sh \
        --unattended \
        --url ${REPOSITORY_URL} \
        --token ${RUNNER_TOKEN} \
        --labels ${_LABELS} \
        --replace \
        --work ${_RUNNER_WORKDIR} \
        --name "${_RUNNER_NAME}" || echo
}

# Opt into runner reusage because a value was given
if [[ -n "${CONFIGURED_ACTIONS_RUNNER_FILES_DIR}" ]]; then
  echo "Runner reusage is enabled"

  # directory exists, copy the data
  if [[ -d "${CONFIGURED_ACTIONS_RUNNER_FILES_DIR}" ]]; then
    echo "Copying previous data"
    cp -p -r "${CONFIGURED_ACTIONS_RUNNER_FILES_DIR}/." "/actions-runner"
  fi

  if [ -f "/actions-runner/.runner" ]; then
    echo "The runner has already been configured"
  else
    configure_runner
  fi
else
  echo "Runner reusage is disabled"
  configure_runner
fi

if [[ -n "${CONFIGURED_ACTIONS_RUNNER_FILES_DIR}" ]]; then
  echo "Reusage is enabled. Storing data to ${CONFIGURED_ACTIONS_RUNNER_FILES_DIR}"
  mkdir -p ${CONFIGURED_ACTIONS_RUNNER_FILES_DIR}
  # Quoting (even with double-quotes) the regexp brokes the copying
  cp -p -r "/actions-runner/_diag" "/actions-runner/svc.sh" /actions-runner/.[^.]* "${CONFIGURED_ACTIONS_RUNNER_FILES_DIR}"
fi

exec /actions-runner/run.sh