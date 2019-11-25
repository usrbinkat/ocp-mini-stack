#!/bin/bash
# Write script to prompt user for pull secret so secrets file can be created safely
# Create a developer.redhat.com account @ https://red.ht/35d7RjV
# Complete profile @ https://cloud.redhat.com/openshift/install/metal/user-provisioned
# Return to https://cloud.redhat.com/openshift/install/metal/user-provisioned
mkdir -p ~/.ccio/ocp-mini-stack
cat <<EOF >~/.ccio/ocp-mini-stack/secrets
secret_SSHPUBKEY=\'$(cat ~/.ssh/id_rsa.pub)\'
secret_PULLSECRET=\'\'
EOF