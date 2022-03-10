#!/bin/bash

#
# Mounts the samba share on the swarm nodes.
#

nodes=$(docker node ls --format "{{.Hostname}}" | grep -v main)

for node in $nodes; do
    ssh -i ../cluster_ed25519 pi@$node sudo mount -a
    echo
done
