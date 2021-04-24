FROM ubuntu:20.04

# set the github runner version
ARG RUNNER_VERSION="2.278.0"

# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y sudo docker.io curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev

# update the base packages and add a non-sudo user
RUN useradd -ms /bin/bash docker -g docker
RUN adduser docker sudo
RUN sudo groupmod -g 117 docker
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# install some additional dependencies
ENV TZ=Europe/London
ENV DEBIAN_FRONTEND=noninteractive
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

# copy over the start.sh script
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]