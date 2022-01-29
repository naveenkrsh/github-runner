# github-runner
github-runner

## Shell Wrapper
```
#!/bin/bash

function github-runner {
    name=github-runner-${1//\//-}
    org=$(dirname $1)
    repo=$(basename $1)
    tag=${3:-latest}
    docker rm -f $name
    docker run -d --restart=always \
        -e REPOSITORY_URL="https://github.com/${org}/${repo}" \
        -e RUNNER_TOKEN="$2" \
        -e RUNNER_NAME="linux-${repo}" \
        -e RUNNER_WORKDIR="/tmp/github-runner-${repo}" \
        -e RUNNER_LABELS="naveen-laptop" \
        -e CONFIGURED_ACTIONS_RUNNER_FILES_DIR="/actions-runner-files/" \
        -v /tmp/github-runner-${repo}:/tmp/github-runner-${repo} \
        --name $name github-runner:latest
}

github-runner github-account-name/repo-name git-action-token
```