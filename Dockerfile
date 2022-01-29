FROM debian:buster

ARG GH_ACTIONS_RUNNER_VERSION=2.286.1
ARG PACKAGES="gnupg2 apt-transport-https ca-certificates software-properties-common pwgen git make curl wget zip libicu-dev build-essential libssl-dev libffi-dev python3-dev python3-pip python3-setuptools"

# install basic stuff
RUN apt-get update \
    && apt-get install -y -q ${PACKAGES} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# # install docker
# RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
#     && apt-key fingerprint 0EBFCD88 \
#     && add-apt-repository \
#        "deb [arch=amd64] https://download.docker.com/linux/debian \
#        $(lsb_release -cs) \
#        stable" \
#     && apt-get update \
#     && apt-get install -y docker-ce-cli \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/* \
#     && curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
#     && chmod +x /usr/local/bin/docker-compose

WORKDIR /actions-runner

# install github actions runner
RUN curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v${GH_ACTIONS_RUNNER_VERSION}/actions-runner-linux-x64-${GH_ACTIONS_RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64.tar.gz \
    && rm -f actions-runner-linux-x64.tar.gz

COPY entrypoint.sh /

CMD /entrypoint.sh