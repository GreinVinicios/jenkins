#!/usr/bin/env bash

# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3945021#set--e--u--x--o-pipefail
set -euo pipefail

DIRNAME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd ${DIRNAME} > /dev/null

JENKINS_IMAGE=${JENKINS_IMAGE:-"jenkins/jenkins:latest"}
PORT=${PORT:-"8080"}
CONTAINER_NAME=${CONTAINER_NAME:-"jenkins"}

function main() {
  createNetwork
  runDockerContainer
  getDefaultPassword
  runLocal
}

function createNetwork(){
  docker network create jenkins || true > /dev/null
}

function runDockerContainer() {
  docker run --rm --name ${CONTAINER_NAME} --detach \
    --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
    --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
    --publish ${PORT}:${PORT} --publish 50000:50000 \
    --volume jenkins-data:/var/jenkins_home \
    --volume jenkins-docker-certs:/certs/client:ro \
    ${JENKINS_IMAGE}
}

function getDefaultPassword() {
  echo "Default password:"
  docker exec -it ${CONTAINER_NAME} cat /var/jenkins_home/secrets/initialAdminPassword && echo
}

function runLocal() {
  echo "http://localhost:8080"
}

main

popd > /dev/null
