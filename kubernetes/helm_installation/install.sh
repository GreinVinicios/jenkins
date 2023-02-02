#!/usr/bin/env bash

# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3945021#set--e--u--x--o-pipefail
set -euo pipefail

DIRNAME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd ${DIRNAME} > /dev/null

KUBE_CONTEXT=${1:-$(kubectl config current-context)}
CHART_VERSION=${CHART_VERSION:-"4.3.0"}
CHART_NAME=${CHART_NAME:-"jenkinsci"}
NAMESPACE=${NAMESPACE:-${CHART_NAME}}

DRY_RUN=${DRY_RUN:-"y"}
if [[ "$DRY_RUN" =~ ^([yY])+$ ]]; then
  DRY_RUN=\ --dry-run
else
  DRY_RUN=""
fi

function main() {
  repoConfig
  install

  namespace_exists=$(kubectl get ns | grep ${NAMESPACE} | awk '{ print $1 }')
  if [[ ${namespace_exists} == ${NAMESPACE} ]]; then
    pod_name=$(kubectl get pods -n ${NAMESPACE} --no-headers | head -1 | awk '{ print $1 }')
    pod_condition=""
    while [ "${pod_condition}" != "Running" ]
    do
      pod_condition=$(kubectl get pod ${pod_name} -o='custom-columns=Status:status.phase' --no-headers)
      echo "Wainting for Jenkins to be Running ..."
      sleep 5
    done

    while [ "${pod_condition}" != "true" ]
    do
      pod_condition=$(kubectl get pod ${pod_name} -o='custom-columns=Ready:status.containerStatuses[0].ready' --no-headers)
      echo "Wainting for Jenkins to be Ready ..."
      sleep 5
    done

    echo ""
    echo ""
    echo ""
    
    getDefaultUser
    getDefaultPassword
    getDefaultURL
  fi
}

function repoConfig() {
  helm repo add jenkins https://charts.jenkins.io > /dev/null
  helm repo update
}

function install() {
  # Values: https://raw.githubusercontent.com/jenkinsci/helm-charts/main/charts/jenkins/values.yaml

  helm install ${CHART_NAME} jenkins/jenkins \
  --namespace ${NAMESPACE} \
  --version ${CHART_VERSION} \
  --kube-context=${KUBE_CONTEXT} \
  --create-namespace \
  -f values.yaml ${DRY_RUN}
}

function getDefaultUser() {
  jsonpath="{.data.jenkins-admin-user}"
  secret=$(kubectl get secret -n ${NAMESPACE} ${CHART_NAME} --context=${KUBE_CONTEXT} -o jsonpath=$jsonpath)
  echo $(echo $secret | base64 --decode)
}

function getDefaultPassword() {
  jsonpath="{.data.jenkins-admin-password}"
  secret=$(kubectl get secret -n ${NAMESPACE} ${CHART_NAME} --context=${KUBE_CONTEXT} -o jsonpath=$jsonpath)
  echo $(echo $secret | base64 --decode)
}

function getDefaultURL() {
  jsonpath="{.spec.ports[0].nodePort}"
  NODE_PORT=$(kubectl get -n ${NAMESPACE} --context=${KUBE_CONTEXT} -o jsonpath=$jsonpath services ${CHART_NAME})
  jsonpath="{.items[0].status.addresses[0].address}"
  NODE_IP=$(kubectl get nodes -n ${NAMESPACE} --context=${KUBE_CONTEXT} -o jsonpath=$jsonpath)
  echo http://$NODE_IP:$NODE_PORT/login
}

main

popd > /dev/null
