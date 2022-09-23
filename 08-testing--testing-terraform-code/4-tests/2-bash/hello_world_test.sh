#!/bin/bash
set -euo pipefail

# Change directory to example
cd ../../2-examples/hello-world

# Create the resources
terraform init
terraform apply -auto-approve

# Wait while the instance boots up
# (Could also use a provisioner in the TF config to do this)
# [
# actually:
# _Should_ use a provisioner within our TF config;
#
#   - sleeping for an arbirary amount of time is hacky;
#
#   - a more robust approach,
#     which is made possible by using a provisioner within our TF config,
#     is to wait on the EC2 instance to come up
# ]
sleep 60

# Query the output [from the applied TF config], extract the IP and make a request
terraform output -json |\
jq -r '.instance_ip_addr.value' |\
xargs -I {} curl http://{}:8080 -m 10

# If request succeeds, destroy the resources
terraform destroy -auto-approve
