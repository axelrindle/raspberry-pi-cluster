#!/bin/bash

set -e

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required, $# provided"

ping -c 1 $1

ssh -i ./cluster_ed25519 pi@$1 << EOF

sudo timedatectl set-timezone Europe/Berlin
sudo apt-get install -y ca-certificates curl gnupg lsb-release

echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bullseye main" | sudo tee /etc/apt/sources.list.d/azlux.list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

sudo apt update
sudo apt install -y log2ram docker-ce

sudo usermod -aG docker pi
sudo docker swarm join --token <INSERT TOKEN HERE> 192.168.178.10:2377

sudo reboot now

EOF
