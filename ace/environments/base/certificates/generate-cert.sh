#!/bin/bash -ex

check_var() {
  file=$1

  if [[ -z ${!file} ]]; then
    echo ensure variable, $file, is set
    exit 1
  fi
}

JKS_CREATE=false

if [[ "$1" == "with-jks" ]]; then
  JKS_CREATE=true
fi

check_var NAME
check_var ISSUER_NAME

IS_CA=${IS_CA:-false}
ISSUER_TYPE=${ISSUER_TYPE:-Issuer}
COMMON_NAME=${COMMON_NAME:-'appdomain.cloud'}
SUBJECT_COUNTRY=${SUBJECT_COUNTRY:-GB}
SUBJECT_PROVINCE=${SUBJECT_PROVINCE:-London}
SUBJECT_LOCALITY=${SUBJECT_LOCALITY:-London}
SUBJECT_ORGANIZATION=${SUBJECT_ORGANIZATION:-IBM}
SUBJECT_ORGANIZATIONAL_UNIT=${SUBJECT_ORGANIZATIONAL_UNIT:-'Assets and Architecture'}

INGRESS_DOMAIN=$(oc get --namespace=openshift-ingress-operator ingresscontroller/default --template="{{.status.domain}}")

oc process \
  -o yaml \
  -f cert-template.yaml \
  -p NAME="${NAME}" \
  -p JKS_CREATE="${JKS_CREATE}" \
  -p IS_CA="${IS_CA}" \
  -p ISSUER_NAME="${ISSUER_NAME}" \
  -p ISSUER_TYPE="${ISSUER_TYPE}" \
  -p COMMON_NAME="${COMMON_NAME}" \
  -p SUBJECT_COUNTRY="${SUBJECT_COUNTRY}" \
  -p SUBJECT_PROVINCE="${SUBJECT_PROVINCE}" \
  -p SUBJECT_LOCALITY="${SUBJECT_LOCALITY}" \
  -p SUBJECT_ORGANIZATION="${SUBJECT_ORGANIZATION}" \
  -p SUBJECT_ORGANIZATIONAL_UNIT="${SUBJECT_ORGANIZATIONAL_UNIT}" \
  -p INGRESS_WILDCARD="*.${INGRESS_DOMAIN}" \
  > ${NAME}.yaml
