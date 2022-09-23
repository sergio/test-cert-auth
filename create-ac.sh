#!/bin/bash

PASSPHRASE=1qaz1qaz
CA_ROOT=$1

rm -rf $CA_ROOT

mkdir -p \
	$CA_ROOT/keys \
	$CA_ROOT/certs \
	$CA_ROOT/csrs \
	$CA_ROOT/config

# Create Certificate Authority
openssl genrsa \
	-aes256 \
	-out $CA_ROOT/ca.key \
	-passout pass:$PASSPHRASE \
	4096

openssl req \
	-new -x509 \
	-key $CA_ROOT/ca.key \
	-days 365 \
	-sha256 \
	-subj "/C=US/O=Incode/OU=RD/CN=ca.local" \
	-passin pass:$PASSPHRASE \
	-out $CA_ROOT/ca.crt

# Server Certificate

echo "subjectAltName = DNS:test.local" > $CA_ROOT/config/server-extfile.cnf

openssl genrsa \
	-aes256 \
	-out $CA_ROOT/keys/server.key \
	-passout pass:$PASSPHRASE \
	4096

openssl req \
	-subj "/CN=test.local" \
	-sha256 -new \
	-key $CA_ROOT/keys/server.key \
	-out $CA_ROOT/csrs/server.csr \
	-passin pass:$PASSPHRASE

openssl x509 \
	-req -days 365 -sha256 \
	-in $CA_ROOT/csrs/server.csr \
	-CA $CA_ROOT/ca.crt \
	-CAkey $CA_ROOT/ca.key \
	-CAcreateserial \
	-out $CA_ROOT/certs/server.crt \
	-extfile $CA_ROOT/config/server-extfile.cnf \
	-passin pass:$PASSPHRASE

# Client Certificate

echo "extendedKeyUsage = clientAuth" > $CA_ROOT/config/client-extfile.cnf

openssl genrsa \
	-aes256 \
	-out $CA_ROOT/keys/client.key \
	-passout pass:$PASSPHRASE \
	4096

openssl req \
	-subj "/CN=client" \
	-sha256 -new \
	-key $CA_ROOT/keys/client.key \
	-out $CA_ROOT/csrs/client.csr \
	-passin pass:$PASSPHRASE

openssl x509 \
	-req -days 365 -sha256 \
	-in $CA_ROOT/csrs/client.csr \
	-CA $CA_ROOT/ca.crt \
	-CAkey $CA_ROOT/ca.key \
	-CAcreateserial \
	-out $CA_ROOT/certs/client.crt \
	-extfile $CA_ROOT/config/client-extfile.cnf \
	-passin pass:$PASSPHRASE

