#!/bin/bash

set -e

source .env

nodes=$(docker node ls --format "{{.Hostname}}" | grep -v main)

for node in $nodes; do
    scp -i ../cluster_ed25519 "./$CA_DIRECTORY/rootCA.crt" pi@$node:~
    ssh -i ../cluster_ed25519 pi@$node << EOF
        sudo mkdir /usr/share/ca-certificates/cluster
        sudo mv ~/rootCA.crt /usr/local/share/ca-certificates
        sudo update-ca-certificates
EOF
done
