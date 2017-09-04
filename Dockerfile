FROM ubuntu:16.04

MAINTAINER TobiLG <tobilg@gmail.com>

# Download dumb-init
ADD https://github.com/Yelp/dumb-init/releases/download/v1.0.2/dumb-init_1.0.2_amd64 /usr/bin/dumb-init

ENV DIND_COMMIT v17.05.0-ce

ENV GITLAB_RUNNER_VERSION=1.11.4

ENV DOCKER_ENGINE_VERSION=17.06

# Install components and do the preparations
# 1. Install needed packages
# 2. Install GitLab CI runner
# 3. Install Docker
# 4. Install DinD hack
# 5. Cleanup
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y ca-certificates apt-transport-https curl dnsutils bridge-utils lsb-release software-properties-common && \
    chmod +x /usr/bin/dumb-init && \
    echo "deb https://packages.gitlab.com/runner/gitlab-ci-multi-runner/ubuntu/ `lsb_release -cs` main" > /etc/apt/sources.list.d/runner_gitlab-ci-multi-runner.list && \
    curl -sSL https://packages.gitlab.com/gpg.key | apt-key add - && \
    apt-get update -y && \
    apt-get install -y gitlab-ci-multi-runner=${GITLAB_RUNNER_VERSION} && \
    mkdir -p /etc/gitlab-runner/certs && \
    chmod -R 700 /etc/gitlab-runner && \
    apt-get update && \
    curl -sSL https://raw.githubusercontent.com/moby/moby/${DIND_COMMIT}/hack/dind -o /usr/local/bin/dind && \
    chmod a+x /usr/local/bin/dind && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
RUN curl https://releases.rancher.com/install-docker/${DOCKER_ENGINE_VERSION}.sh | sh 

# Add wrapper script
ADD register_and_run.sh /

# Expose volumes
VOLUME ["/var/lib/docker", "/etc/gitlab-runner", "/home/gitlab-runner"]

ENTRYPOINT ["/usr/bin/dumb-init", "/register_and_run.sh"]
