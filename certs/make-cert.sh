#!/bin/bash

set -e

source .env

if [ ! -d "$CA_DIRECTORY" ]; then
    echo >&2 "No CA has been created! Use \"./make-ca.sh\" for that."
    exit 1
fi
if [ -d "$CERT_DIRECTORY" ]; then
    echo >&2 "The directory \"$CERT_DIRECTORY\" does already exist!"
    exit 1
fi

mkdir "$CERT_DIRECTORY"
cp req.conf.example "$CERT_DIRECTORY/req.conf"
cd "$CERT_DIRECTORY"

prefix=cluster

openssl genrsa -out $prefix.key 2048
openssl req -subj "/CN=$prefix" -extensions v3_req -sha256 -new -key $prefix.key -out $prefix.csr
openssl x509 -req -extensions v3_req -days 3650 -sha256 \
    -in $prefix.csr \
    -CA "../$CA_DIRECTORY/rootCA.crt" \
    -CAkey "../$CA_DIRECTORY/rootCA.key" \
    -CAcreateserial \
    -out "$prefix.crt" \
    -extfile "req.conf"
