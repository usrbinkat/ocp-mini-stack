#!/bin/bash
# Write script to prompt user for pull secret so secrets file can be created safely
# https://cloud.redhat.com/openshift/install/metal/user-provisioned
mkdir -p ~/.ccio/ocp-mini-stack
cat <<EOF >~/.ccio/ocp-mini-stack/secrets
secret_SSHPUBKEY=\'$(cat ~/.ssh/id_rsa.pub)\'
secret_PULLSECRET=\'\'
EOF
