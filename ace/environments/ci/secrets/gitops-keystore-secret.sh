#!/usr/bin/env bash

set -eo pipefail

if [ -z ${STORE_TYPE} ]; then echo "Please set STORE_TYPE when running script"; exit 1; fi
if [ -z ${SECRET_NAME} ]; then echo "Please set STORE_TYPE when running script"; exit 1; fi
if [ -z ${SOURCE_SECRET} ]; then echo "Please set STORE_TYPE when running script"; exit 1; fi

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

STORE_VALUE=$(oc get secret ${SOURCE_SECRET} -o jsonpath="{.data.${STORE_TYPE}\.jks}")

oc create secret generic \
  ${SECRET_NAME} \
  --from-literal configuration=${STORE_VALUE} \
  --dry-run=client -o yaml \
  | oc label -f- \
    created-by=pipeline \
    --local \
    --dry-run=client -o yaml \
  | kubeseal \
    --scope cluster-wide \
    --controller-name=${SEALED_SECRET_CONTOLLER_NAME} \
    --controller-namespace=${SEALED_SECRET_NAMESPACE} \
    -o yaml > ${SECRET_NAME}.yaml