#!/bin/bash
source $(pwd)/src/stage-pull-secrets.sh
cat <<EOF >$(pwd)/ignition/install-config.yaml
apiVersion: v1
baseDomain: braincraft.io
compute:
- hyperthreading: Enabled   
  name: worker
  replicas: 0 
controlPlane:
  hyperthreading: Enabled   
  name: master 
  replicas: 3 
metadata:
  name: ocp4 
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14 
    hostPrefix: 23 
  networkType: OpenShiftSDN
  serviceNetwork: 
  - 172.30.0.0/16
platform:
  none: {} 
pullSecret: ${secret_PULLSECRET}
sshKey: ${secret_SSHPUBKEY}
EOF
