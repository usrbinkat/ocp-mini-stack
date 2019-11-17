LOCAL_TAG=v3.11.59

IMAGES_CORE="apb-base apb-tools automation-broker-apb csi-attacher csi-driver-registrar csi-livenessprobe csi-provisioner grafana image-inspector mariadb-apb mediawiki mediawiki-apb mysql-apb ose-ansible ose-ansible-service-broker ose-cli ose-cluster-autoscaler ose-cluster-capacity ose-cluster-monitoring-operator ose-console ose-configmap-reloader ose-control-plane ose-deployer ose-descheduler ose-docker-builder"

time for image in ${IMAGES_CORE}
do
  echo "Copying image: $image"
  skopeo copy --dest-tls-verify=false docker://registry.redhat.io/openshift3/${image}:${LOCAL_TAG} docker://localhost:5000/openshift3/${image}:${LOCAL_TAG}
  echo "Copied image: $image"
done
