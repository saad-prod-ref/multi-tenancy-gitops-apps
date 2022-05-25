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
check_var STORE_TYPE

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

oc extract secret/${SOURCE_SECRET} --keys=${STORE_TYPE}.jks --to=/tmp --confirm -n dev

oc create secret generic \
  ${NAME}.jks \
  --from-file configuration=/tmp/${STORE_TYPE}.jks \
  --dry-run=client -o yaml \
  | oc label -f- \
    created-by=pipeline \
    --local \
    --dry-run=client -o yaml \
  | kubeseal \
    --scope cluster-wide \
    --controller-name=${SEALED_SECRET_CONTOLLER_NAME} \
    --controller-namespace=${SEALED_SECRET_NAMESPACE} \
    -o yaml > ${NAME}-jks.yaml
