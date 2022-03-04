# Certificate Automation

This directory contains scripts to automatically create a self-signed certificate authority (CA) & certificate. The authority can be installed onto all the swarm nodes, which will enable acceptance of certificates signed with this authority. A good use case is the usage with a custom Docker Registry.

## Workflow

1. Create the CA: `./make-ca.sh`
2. Create the SAN certificate: `./make-cert.sh`
3. Install the CA onto all nodes of the Docker Swarm: `./install-ca.sh`

Most of the scripts will ask questions about the certificate.

## Customization

Paths may be configured via the `.env` file.

## References

Tutorial (CA): https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309
Tutorial (SAN): https://fabianlee.org/2018/02/17/ubuntu-creating-a-trusted-ca-and-san-certificate-using-openssl-on-ubuntu/
