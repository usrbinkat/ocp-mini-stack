S2I_BUILDER_IMAGES="openshift3/jenkins-slave-base-rhel7 openshift3/jenkins-slave-maven-rhel7 openshift3/jenkins-slave-nodejs-rhel7 rhscl/mongodb-32-rhel7 rhscl/mysql-57-rhel7 rhscl/perl-524-rhel7 rhscl/php-56-rhel7 rhscl/postgresql-95-rhel7 rhscl/python-35-rhel7 redhat-sso-7/sso70-openshift rhscl/ruby-24-rhel7 redhat-openjdk-18/openjdk18-openshift redhat-sso-7/sso71-openshift rhscl/nodejs-6-rhel7 rhscl/mariadb-101-rhel7"

time for image in ${S2I_BUILDER_IMAGES}
do
  echo "Copying image: $image"
  skopeo copy --dest-tls-verify=false docker://registry.redhat.io/${image} docker://localhost:5000/${image}
  echo "Copied image: $image"
done
