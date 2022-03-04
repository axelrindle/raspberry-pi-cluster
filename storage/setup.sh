#!/bin/bash

set -e

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required, $# provided"

ping -c 1 $1

scp -i ../cluster_ed25519 .smb_credentials pi@$1:~
ssh -i ../cluster_ed25519 pi@$1 << EOF

sudo apt-get install -y cifs-utils

sudo mkdir /mnt/send_storage

sudo mount -a

EOF
