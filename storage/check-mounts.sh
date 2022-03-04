#!/bin/bash

#
# Checks whether the samba share is mounted on the swarm nodes.
#

nodes=$(docker node ls --format "{{.Hostname}}" | grep -v main)

for node in $nodes; do
    ssh -i ../cluster_ed25519 pi@$node mount | grep send_storage
    echo
done
