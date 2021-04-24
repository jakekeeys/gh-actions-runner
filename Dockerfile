FROM ubuntu:20.04

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y sudo docker.io curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev

ENV TZ=Europe/London
ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_VERSION="2.278.0"
ENV RUNNER_ALLOW_RUNASROOT=1

COPY start.sh start.sh
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]
