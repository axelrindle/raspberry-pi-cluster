#!/bin/bash

nodes=$(docker node ls --format "{{.Hostname}}" | grep -v main)

for node in $nodes; do
    ssh -i ./cluster_ed25519 pi@$node sudo shutdown now
done

sudo shutdown now
