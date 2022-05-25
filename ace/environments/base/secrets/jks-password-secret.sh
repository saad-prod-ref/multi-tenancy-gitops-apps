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

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

oc create secret generic \
  ${NAME}-jks-password \
  --from-literal password=$(ruby -rsecurerandom -e 'puts SecureRandom.hex(8)') \
  --dry-run=client -o yaml \
  | oc label -f- \
    created-by=pipeline \
    --local \
    --dry-run=client -o yaml \
  | kubeseal \
    --scope cluster-wide \
    --controller-name=${SEALED_SECRET_CONTOLLER_NAME} \
    --controller-namespace=${SEALED_SECRET_NAMESPACE} \
    -o yaml > ${NAME}-password.yaml
