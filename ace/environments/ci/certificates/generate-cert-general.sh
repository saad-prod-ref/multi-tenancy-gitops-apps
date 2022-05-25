#!/bin/bash -e

if [ -z ${NAME} ]; then echo "Please set NAME when running script"; exit 1; fi
if [ -z ${ORG_UNIT} ]; then echo "Please set NAME when running script"; exit 1; fi

INGRESS_DOMAIN=$(oc get --namespace=openshift-ingress-operator ingresscontroller/default --template="{{.status.domain}}")

oc process \
  -o yaml \
  -f prod-ref-cert-template.yaml \
  -p INGRESS_WILDCARD="*.${INGRESS_DOMAIN}" \
  -p NAME=${NAME} \
  -p ORG_UNIT=${ORG_UNIT} \
  > ${NAME}.yaml
