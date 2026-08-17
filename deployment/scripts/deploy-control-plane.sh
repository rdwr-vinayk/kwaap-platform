#!/bin/bash

set -e

KWAAP_NS=kwaf
APP_NS=test

REGISTRY=714010226847.dkr.ecr.ap-south-1.amazonaws.com/kwaap
VERSION=:1.25.0

SIG_REGISTRY=714010226847.dkr.ecr.ap-south-1.amazonaws.com/kwaap
SIG_VERSION=:601

CRD_VERSION=v1
ISTIO_VERSION=1.28.3

aws eks update-kubeconfig --name eks-control-plane


cd /tmp

aws s3 cp s3://vinay-kwaap-bucket/waas_helm3-1.25.0.tgz .
aws s3 cp s3://vinay-kwaap-bucket/sample-apps-ext-authz-aws.tar .
aws s3 cp s3://vinay-kwaap-bucket/nginx-lua-vin.zip .

tar -zxvf waas_helm3-1.25.0.tgz


kubectl create ns ${KWAAP_NS} \
--dry-run=client -o yaml | kubectl apply -f -

kubectl create ns ${APP_NS} \
--dry-run=client -o yaml | kubectl apply -f -

kubectl label ns ${KWAAP_NS} \
istio-injection=enabled \
--overwrite

kubectl label ns ${APP_NS} \
istio-injection=enabled \
--overwrite

curl -L https://istio.io/downloadIstio | \
ISTIO_VERSION=${ISTIO_VERSION} \
TARGET_ARCH=x86_64 sh -

./istio-${ISTIO_VERSION}/bin/istioctl install -y \
--set profile=default \
--set components.ingressGateways[0].enabled=false \
--set hub=gcr.io/istio-release \
--set values.global.imagePullPolicy=IfNotPresent


helm upgrade --install \
--namespace ${KWAAP_NS} \
--create-namespace \
--wait \
waas-crd \
waas/custom-resources/${CRD_VERSION}