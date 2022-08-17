#!/usr/bin/env bash
set -euo pipefail

DIRNAME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $DIRNAME > /dev/null

DOCKER_USER=${1:-''}'/'
JENKINS_VERSION=1.0.0
JENKINS_IMAGENAME=jenkins-custom

function main(){
  build
  run
  getPaswd
}

function build(){
  if [[ ${DOCKER_USER} = "/" ]]; then
    echo "Building ${JENKINS_IMAGENAME}:${JENKINS_VERSION} ..."
    docker build -t ${JENKINS_IMAGENAME}:${JENKINS_VERSION} .
  else
    echo "Building ${DOCKER_USER}${JENKINS_IMAGENAME}:${JENKINS_VERSION} ..."
    docker build -t ${DOCKER_USER}${JENKINS_IMAGENAME}:${JENKINS_VERSION} . &&
    echo "Pushing ${DOCKER_USER}${JENKINS_IMAGENAME}:${JENKINS_VERSION} ..."
    docker push ${DOCKER_USER}${JENKINS_IMAGENAME}:${JENKINS_VERSION}
  fi
}

function run(){
  echo "Running Jenkins ..."
  docker run --name ${JENKINS_IMAGENAME} -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home \
  --restart=on-failure \
  ${DOCKER_USER}${JENKINS_IMAGENAME}:${JENKINS_VERSION}
}

function getPaswd(){
  echo "Getting Jenkins inicial admin password ..."

  for i in {1..5}; do docker container exec ${JENKINS_IMAGENAME} cat /var/jenkins_home/secrets/initialAdminPassword 2> /dev/null && break || sleep 5; done

  echo "Open http://127.0.0.1:8080/"
}

main

popd > /dev/null
