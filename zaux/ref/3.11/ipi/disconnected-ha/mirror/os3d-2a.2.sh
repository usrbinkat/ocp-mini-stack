LOCAL_TAG=v3.11.59
IMAGES_CORE="ose-docker-registry ose-efs-provisioner ose-egress-dns-proxy ose-egress-http-proxy ose-egress-router ose-haproxy-router ose-hyperkube ose-hypershift ose-keepalived-ipfailover ose-kube-rbac-proxy ose-kube-state-metrics ose-metrics-server ose-node ose-node-problem-detector ose-operator-lifecycle-manager ose-pod ose-prometheus-config-reloader ose-prometheus-operator ose-recycler ose-service-catalog ose-template-service-broker ose-web-console postgresql-apb registry-console snapshot-controller snapshot-provisioner"

time for image in ${IMAGES_CORE}
do
  echo "Copying image: $image"
  skopeo copy --dest-tls-verify=false docker://registry.redhat.io/openshift3/${image}:${LOCAL_TAG} docker://localhost:5000/openshift3/${image}:${LOCAL_TAG}
  echo "Copied image: $image"
done
