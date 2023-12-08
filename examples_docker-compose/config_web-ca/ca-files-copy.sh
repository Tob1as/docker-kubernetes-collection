#!/bin/sh
set -e

EASY_RSA_PATH=../easy-rsa  # change this path
WEB_CA_PKI_PATH=$(dirname "$0")/pki

echo ">> copy CAs"
cp ${EASY_RSA_PATH}/root-ca/ca.crt ${WEB_CA_PKI_PATH}/ca.crt
cp ${EASY_RSA_PATH}/intermediate-ca/ca.crt ${WEB_CA_PKI_PATH}/intermediate-ca.crt

echo ">> create fullCA"
cat ${EASY_RSA_PATH}/intermediate-ca/ca.crt > ${WEB_CA_PKI_PATH}/fullca.crt
cat ${EASY_RSA_PATH}/root-ca/ca.crt >> ${WEB_CA_PKI_PATH}/fullca.crt

echo ">> copy CRLs"
cp ${EASY_RSA_PATH}/root-ca/crl.pem ${WEB_CA_PKI_PATH}/ca.crl
cp ${EASY_RSA_PATH}/intermediate-ca/crl.pem ${WEB_CA_PKI_PATH}/intermediate-ca.crl

echo ">> set permission (chmod)"
chmod 644 ${WEB_CA_PKI_PATH}/*
