#!/bin/bash

set -e

# create secrets for elastic, validation controller and GUI
# self signed CA
TLS_DIR=kwaf_tls
NAMESPACE=${KWAAP_NS}
MDIR=${TLS_DIR}/manifests

mkdir -p ${TLS_DIR}/_ca
mkdir ${MDIR}

CA_CN=${NAMESPACE}.svc

openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout ${TLS_DIR}/_ca/ca.key \
  -out ${TLS_DIR}/_ca/ca.crt \
  -subj "/CN=${CA_CN}"

CM_NAME="waas-ca-config"
kubectl create configmap ${CM_NAME} --from-file=${TLS_DIR}/_ca/ca.crt --namespace ${NAMESPACE} --dry-run=client -o yaml > ${MDIR}/${CM_NAME}.yaml

# self signed server certificate, elastic
SERVICE=waas-elasticsearch-exposed
SRV_CN=${SERVICE}.${NAMESPACE}.svc
SERVER_DIR=${TLS_DIR}/${SERVICE}/server
mkdir -p ${SERVER_DIR}
openssl genrsa -out ${SERVER_DIR}/server_pkcs1.key 2048 &> /dev/null
openssl pkcs8 -topk8 -inform pem -in ${SERVER_DIR}/server_pkcs1.key -outform PEM -nocrypt -out ${SERVER_DIR}/server.key &> /dev/null
openssl req -new \
    -key ${SERVER_DIR}/server.key \
    -out ${SERVER_DIR}/server.csr \
    -subj "/CN=${SRV_CN}"\
    -addext "subjectAltName = DNS:${SRV_CN}" \
    -addext "extendedKeyUsage = serverAuth, clientAuth" &> /dev/null
openssl x509 -req -days 365 -in ${SERVER_DIR}/server.csr \
    -CA ${TLS_DIR}/_ca/ca.crt -CAkey ${TLS_DIR}/_ca/ca.key \
    -CAcreateserial -out ${SERVER_DIR}/server.crt \
    -extfile <(printf "subjectAltName=DNS:${SRV_CN}\nextendedKeyUsage=serverAuth, clientAuth") &> /dev/null

SRV_SECRET_NAME="${SERVICE}-server-secret"
kubectl create secret tls ${SRV_SECRET_NAME} \
  --key ${TLS_DIR}/${SERVICE}/server/server.key \
  --cert ${TLS_DIR}/${SERVICE}/server/server.crt \
  --namespace ${NAMESPACE} \
  --dry-run=client -o yaml > ${MDIR}/${SRV_SECRET_NAME}.yaml

# self signed server certificate, validation controller
SERVICE=waas-validation-controller
SRV_CN=${SERVICE}.${NAMESPACE}.svc
SERVER_DIR=${TLS_DIR}/${SERVICE}/server
mkdir -p ${SERVER_DIR}
openssl genrsa -out ${SERVER_DIR}/server_pkcs1.key 2048 &> /dev/null
openssl pkcs8 -topk8 -inform pem -in ${SERVER_DIR}/server_pkcs1.key -outform PEM -nocrypt -out ${SERVER_DIR}/server.key &> /dev/null
openssl req -new \
    -key ${SERVER_DIR}/server.key \
    -out ${SERVER_DIR}/server.csr \
    -subj "/CN=${SRV_CN}"\
    -addext "subjectAltName = DNS:${SRV_CN}" \
    -addext "extendedKeyUsage = serverAuth, clientAuth" &> /dev/null
openssl x509 -req -days 365 -in ${SERVER_DIR}/server.csr \
    -CA ${TLS_DIR}/_ca/ca.crt -CAkey ${TLS_DIR}/_ca/ca.key \
    -CAcreateserial -out ${SERVER_DIR}/server.crt \
    -extfile <(printf "subjectAltName=DNS:${SRV_CN}\nextendedKeyUsage=serverAuth, clientAuth") &> /dev/null

SRV_SECRET_NAME="${SERVICE}-server-secret"
kubectl create secret tls ${SRV_SECRET_NAME} \
  --key ${TLS_DIR}/${SERVICE}/server/server.key \
  --cert ${TLS_DIR}/${SERVICE}/server/server.crt \
  --namespace ${NAMESPACE} \
  --dry-run=client -o yaml > ${MDIR}/${SRV_SECRET_NAME}.yaml

# self signed server certificate, GUI
SERVICE=waas-gui
SRV_CN=${SERVICE}.${NAMESPACE}.svc
SERVER_DIR=${TLS_DIR}/${SERVICE}/server
mkdir -p ${SERVER_DIR}
openssl genrsa -out ${SERVER_DIR}/server_pkcs1.key 2048 &> /dev/null
openssl pkcs8 -topk8 -inform pem -in ${SERVER_DIR}/server_pkcs1.key -outform PEM -nocrypt -out ${SERVER_DIR}/server.key &> /dev/null
openssl req -new \
    -key ${SERVER_DIR}/server.key \
    -out ${SERVER_DIR}/server.csr \
    -subj "/CN=${SRV_CN}"\
    -addext "subjectAltName = DNS:${SRV_CN}" \
    -addext "extendedKeyUsage = serverAuth, clientAuth" &> /dev/null
openssl x509 -req -days 365 -in ${SERVER_DIR}/server.csr \
    -CA ${TLS_DIR}/_ca/ca.crt -CAkey ${TLS_DIR}/_ca/ca.key \
    -CAcreateserial -out ${SERVER_DIR}/server.crt \
    -extfile <(printf "subjectAltName=DNS:${SRV_CN}\nextendedKeyUsage=serverAuth, clientAuth") &> /dev/null

srv_secret_name="${SERVICE}-server-secret"
kubectl create secret tls ${srv_secret_name} \
  --key ${TLS_DIR}/${SERVICE}/server/server.key \
  --cert ${TLS_DIR}/${SERVICE}/server/server.crt \
  --namespace ${NAMESPACE} \
  --dry-run=client -o yaml > ${MDIR}/${srv_secret_name}.yaml

kubectl apply -f ${MDIR}
