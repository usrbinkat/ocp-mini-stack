wget -qO- https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux-4.2.4.tar.gz \
    | sudo tar -zxvf - -C /bin/ openshift-install
wget -qO- https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-4.2.4.tar.gz \
    | sudo tar -zxvf - -C /bin/ oc kubectl
https://blog.openshift.com/openshift-4-bare-metal-install-quickstart/

