#!/bin/bash


gcloud compute instance-templates list | grep td-vm-template > /dev/null 2>&1

if [ $? -ne 0 ] ; then
    gcloud compute instance-templates create td-vm-template \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --tags=http-td-tag,http-server,https-server \
    --image-family=debian-9 \
    --image-project=debian-cloud \
    --metadata=startup-script="#! /bin/bash

    # Add a system user to run Envoy binaries. Login is disabled for this user
    sudo adduser --system --disabled-login envoy
    # Download and extract the Traffic Director tar.gz file
    sudo wget -P /home/envoy https://storage.googleapis.com/traffic-director/traffic-director.tar.gz
    sudo tar -xzf /home/envoy/traffic-director.tar.gz -C /home/envoy
    sudo cat << END > /home/envoy/traffic-director/sidecar.env
    ENVOY_USER=envoy
    # Exclude the proxy user from redirection so that traffic doesn't loop back
    # to the proxy
    EXCLUDE_ENVOY_USER_FROM_INTERCEPT='true'
    # Intercept all traffic by default
    SERVICE_CIDR='*'
    GCP_PROJECT_NUMBER=''
    VPC_NETWORK_NAME=''
    ENVOY_PORT='15001'
    ENVOY_ADMIN_PORT='15000'
    LOG_DIR='/var/log/envoy/'
    LOG_LEVEL='info'
    XDS_SERVER_CERT='/etc/ssl/certs/ca-certificates.crt'
    END
    sudo apt-get update -y
    sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/debian stretch stable' -y
    sudo apt-get update -y
    sudo apt-get install docker-ce apache2 -y
    sudo service apache2 restart
    echo '<!doctype html><html><body><h1>'\`/bin/hostname\`'</h1></body></html>' | sudo tee /var/www/html/index.html
    sudo /home/envoy/traffic-director/pull_envoy.sh
    sudo /home/envoy/traffic-director/run.sh start"
fi

gcloud compute instance-groups managed list | grep td-vm-mig-us-central1 > /dev/null 2>&1

if [ $? -ne 0 ] ; then
    gcloud compute instance-groups managed create td-vm-mig-us-central1 \
        --zone us-central1-a --size=2 --template=td-vm-template
fi

gcloud compute health-checks list | grep td-vm-health-check > /dev/null 2>&1

if [ $? -ne 0 ] ; then
    gcloud compute health-checks create http td-vm-health-check
fi

gcloud compute firewall-rules list  | grep fw-allow-health-checks > /dev/null 2>&1
if [ $? -ne 0 ] ; then
    gcloud compute firewall-rules create fw-allow-health-checks \
  --action ALLOW \
  --direction INGRESS \
  --source-ranges 35.191.0.0/16,130.211.0.0/22 \
  --target-tags http-td-tag,http-server,https-server \
  --rules tcp
fi

gcloud compute backend-services list | grep td-vm-service > /dev/null 2>&1
if [ $? -ne 0 ] ; then
    gcloud compute backend-services create td-vm-service \
    --global \
    --load-balancing-scheme=INTERNAL_SELF_MANAGED \
    --health-checks td-vm-health-check

    gcloud compute backend-services add-backend td-vm-service \
    --instance-group td-vm-mig-us-central1 \
    --instance-group-zone us-central1-a \
    --global
fi

gcloud compute url-maps list | grep td-vm-url-map > /dev/null 2>&1
if [ $? -ne 0 ] ; then
    gcloud compute url-maps create td-vm-url-map \
   --default-service td-vm-service

    gcloud compute url-maps add-path-matcher td-vm-url-map \
   --default-service td-vm-service --path-matcher-name td-vm-path-matcher

    gcloud compute url-maps add-host-rule td-vm-url-map --hosts service-test \
   --path-matcher-name td-vm-path-matcher

    gcloud compute target-http-proxies create td-vm-proxy \
   --url-map td-vm-url-map
fi

gcloud compute forwarding-rules list | grep td-vm-forwarding-rule > /dev/null 2>&1
if [ $? -ne 0 ] ; then
    gcloud compute forwarding-rules create td-vm-forwarding-rule \
   --global \
   --load-balancing-scheme=INTERNAL_SELF_MANAGED \
   --address=0.0.0.0 \
   --target-http-proxy=td-vm-proxy \
   --ports 80 \
   --network default
fi