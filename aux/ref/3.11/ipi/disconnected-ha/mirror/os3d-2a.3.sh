IMAGES_CRITICAL="rhel7/etcd:3.2.22"
time for image in ${IMAGES_CRITICAL}
do
  skopeo copy --dest-tls-verify=false docker://registry.redhat.io/${image} docker://localhost:5000/${image}
  echo "Copied image: $image"
done
