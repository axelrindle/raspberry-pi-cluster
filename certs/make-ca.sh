#!/bin/bash

set -e

source .env

if [ -d "$CA_DIRECTORY" ]; then
    echo >&2 "The directory \"$CA_DIRECTORY\" does already exist!"
    exit 1
fi

mkdir "$CA_DIRECTORY"
cd "$CA_DIRECTORY"

openssl genrsa -des3 -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt
