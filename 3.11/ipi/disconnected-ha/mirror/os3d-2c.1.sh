# Nexus and Gogs (latest) from docker.io
for image in sonatype/nexus3 wkulhanek/gogs
do
  skopeo copy --dest-tls-verify=false docker://docker.io/${image}:latest docker://localhost:5000/${image}:latest
done

# even more recent postgresql and jboss-eap to support nexus and gogs
for image in rhscl/postgresql-96-rhel7 jboss-eap-7/eap71-openshift
do
  skopeo copy --dest-tls-verify=false docker://registry.access.redhat.com/$image:latest docker://localhost:5000/${image}:latest
done
