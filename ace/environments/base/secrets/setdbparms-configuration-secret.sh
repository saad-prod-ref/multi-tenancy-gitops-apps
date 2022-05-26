#!/usr/bin/env bash

set -eo pipefail

check_var() {
  file=$1

  if [[ -z ${!file} ]]; then
    echo ensure variable, $file, is set
    exit 1
  fi
}

check_var NAME
check_var SOURCE_SECRET
check_var PASSWORD_KEY

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

PASSWORD_VALUE=$(oc get secret ${SOURCE_SECRET} -o jsonpath='{.data.password}' | base64 -d)

oc create secret generic \
  ${NAME}-${PASSWORD_KEY}-setdbparms \
  --from-literal configuration="mqsisetdbparms -w /home/aceuser/ace-server -n setdbparms::${PASSWORD_KEY} -u ${PASSWORD_KEY}pwd -p ${PASSWORD_VALUE}" \
  --dry-run=client -o yaml \
  | oc label -f- \
    created-by=pipeline \
    --local \
    --dry-run=client -o yaml \
  | kubeseal \
    --scope cluster-wide \
    --controller-name=${SEALED_SECRET_CONTOLLER_NAME} \
    --controller-namespace=${SEALED_SECRET_NAMESPACE} \
    -o yaml > ${NAME}-${PASSWORD_KEY}-setdbparms.yaml
