LOCAL_TAG=v3.11.59
IMAGES_ADDITIONAL="metrics-cassandra metrics-hawkular-metrics metrics-hawkular-openshift-agent metrics-heapster oauth-proxy ose-logging-curator5 ose-logging-elasticsearch5 ose-logging-eventrouter ose-logging-fluentd ose-logging-kibana5 ose-metrics-schema-installer prometheus prometheus-alert-buffer prometheus-alertmanager prometheus-node-exporter metrics-schema-installer"

time for image in ${IMAGES_ADDITIONAL}
do
  echo "Copying image: $image"
  skopeo copy --dest-tls-verify=false docker://registry.redhat.io/openshift3/${image}:${LOCAL_TAG} docker://localhost:5000/openshift3/${image}:${LOCAL_TAG}
  echo "Copied image: $image"
done
