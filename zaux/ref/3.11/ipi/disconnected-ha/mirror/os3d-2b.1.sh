S2I_BUILDER_IMAGES="jboss-amq-6/amq63-openshift jboss-datagrid-7/datagrid71-openshift jboss-datagrid-7/datagrid71-client-openshift jboss-datavirt-6/datavirt63-openshift jboss-datavirt-6/datavirt63-driver-openshift jboss-decisionserver-6/decisionserver64-openshift jboss-processserver-6/processserver64-openshift jboss-eap-6/eap64-openshift jboss-eap-7/eap71-openshift jboss-eap-7/eap71-openshift jboss-webserver-3/webserver31-tomcat7-openshift jboss-webserver-3/webserver31-tomcat8-openshift openshift3/jenkins-2-rhel7 openshift3/jenkins-agent-maven-35-rhel7 openshift3/jenkins-agent-nodejs-8-rhel7"
time for image in ${S2I_BUILDER_IMAGES}
do
  echo "Copying image: $image"
  skopeo copy --dest-tls-verify=false docker://registry.redhat.io/${image} docker://localhost:5000/${image}
  echo "Copied image: $image"
done
