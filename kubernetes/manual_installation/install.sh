#!/usr/bin/env bash

# https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3945021#set--e--u--x--o-pipefail
set -euo pipefail

DIRNAME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd ${DIRNAME} > /dev/null

KUBE_CONTEXT=${1:-$(kubectl config current-context)}
NAMESPACE=${NAMESPACE:-"jenkinsci"}
DRY_RUN=${DRY_RUN:-"y"}

if [[ "${DRY_RUN}" =~ ^([yY])+$ ]]; then
  echo "DRY-RUN mode activated"
  DRY_RUN=\ '--dry-run=client -o json'
else
  DRY_RUN=""
fi

function main() {
  applyFiles

  namespace_exists=$(kubectl get ns | grep ${NAMESPACE} | awk '{ print $1 }')
  if [[ ${namespace_exists} == ${NAMESPACE} ]]; then
    pod_name=$(kubectl get pods -n ${NAMESPACE} --no-headers | head -1 | awk '{ print $1 }')
    pod_condition=""
    while [ "${pod_condition}" != "Running" ]
    do
      pod_condition=$(kubectl get pod ${pod_name} -n ${NAMESPACE} -o='custom-columns=Status:status.phase' --no-headers)
      echo "Wainting for Jenkins to be Running ..."
      sleep 5
    done

    while [ "${pod_condition}" != "true" ]
    do
      pod_condition=$(kubectl get pod ${pod_name} -n ${NAMESPACE} -o='custom-columns=Ready:status.containerStatuses[0].ready' --no-headers)
      echo "Wainting for Jenkins to be Ready ..."
      sleep 5
    done

    echo ""
    echo ""
    echo ""
    getDefaultPassword ${pod_name}
    showURL
  fi
}

function applyFiles() {
  
  cp namespace.yaml namespace_tmp.yaml
  sed -i 's/custom_namespace/'${NAMESPACE}'/' namespace_tmp.yaml
  kubectl apply -f namespace_tmp.yaml $DRY_RUN
  rm namespace_tmp.yaml

  kubectl apply -f serviceAccount.yaml $DRY_RUN -n $NAMESPACE

  cp roles.yaml roles_tmp.yaml
  sed -i 's/custom_namespace/'${NAMESPACE}'/' roles_tmp.yaml
  kubectl apply -f roles_tmp.yaml $DRY_RUN
  rm roles_tmp.yaml

  kubectl apply -f storageClass.yaml $DRY_RUN
  
  kubectl apply -f volume.yaml $DRY_RUN -n $NAMESPACE
  kubectl apply -f deployment.yaml $DRY_RUN -n $NAMESPACE
  kubectl apply -f service.yaml $DRY_RUN -n $NAMESPACE
}

function getDefaultPassword() {
  pod_name=$1
  echo "Defaul password:"
  kubectl exec --namespace ${NAMESPACE} -it pod/${pod_name} -c jenkins --context=${KUBE_CONTEXT} -- /bin/cat /var/jenkins_home/secrets/initialAdminPassword && echo
}

function showURL() {
  node_name=$(kubectl get pod -o='custom-columns=NodeName:spec.nodeName' --no-headers)
  node_ip=$(kubectl get nodes ${node_name} -o='custom-columns=NodeName:status.addresses[0].address' --no-headers)

  echo "To open Jenkins:"
  echo "http://${node_ip}:32000"
}

main

popd > /dev/null
