#!/bin/bash

echo "Starting with network testing setup script"
PROJECT_ID=`gcloud config get-value project` 
PROJECT_NUMBER=`gcloud projects describe ${PROJECT_ID} --format="csv(projectNumber)" | tail -1`
echo "Project ID: ${PROJECT_ID}; Project number: ${PROJECT_NUMBER}"

SERVICE_ACOUNT=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com
MACHINE_TYPE=n1-standard-4
#PREEMPTIBLE=--preemptible
REGIONS=`gcloud compute regions list | grep -v NAME | awk '{print $1}' | uniq`
NETWORK_NAME=network-latency-test-vpc

echo "Enabling service compute.googleapis.com"
gcloud services enable --project $PROJECT_ID compute.googleapis.com 

gcloud compute --project=${PROJECT_ID} networks list | grep ${NETWORK_NAME} > /dev/null 2>&1
if [ $? -ne 0 ] ; then
  echo "Creating network ${NETWORK_NAME} and automated subnets"
  gcloud compute --project=${PROJECT_ID} networks create ${NETWORK_NAME} --subnet-mode=auto
fi

echo "Now Creating VM in each region"
for REGION in $REGIONS ; do

  ZONE=`gcloud compute zones list | grep $REGION | tail -1 | awk '{print $1}'`

  gcloud compute instances list --project=${PROJECT_ID} --zones=${ZONE} | grep ${ZONE}-nw-test-vm > /dev/null 2>&1
  if [ $? -ne 0 ] ; then

    echo "Creating ${ZONE}-nw-test-vm... in region $REGION"
    time gcloud beta compute --project=${PROJECT_ID} \
    instances create ${ZONE}-nw-test-vm \
    --zone=${ZONE} \
    --machine-type=${MACHINE_TYPE} ${PREEMPTIBLE} \
    --network-tier=STANDARD \
    --network=${NETWORK_NAME} \
    --maintenance-policy=MIGRATE \
    --service-account=${SERVICE_ACCOUNT} \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --image=ubuntu-1604-xenial-v20191217 \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=30GB \
    --tags=nw-test-vm \
    --boot-disk-type=pd-ssd 
  fi

done

gcloud compute --project ${PROJECT_ID} firewall-rules list | grep fw-${NETWORK_NAME}-internal  > /dev/null 2>&1
if [ $? -ne 0 ] ; then
  echo "Creating FW fw-${NETWORK_NAME}-test"
  gcloud compute --project ${PROJECT_ID} firewall-rules create  fw-${NETWORK_NAME}-test \
    --direction=INGRESS --priority=800 \
    --network=${NETWORK_NAME} \
    --action=ALLOW \
    --target-tags=nw-test-vm \
    --rules=tcp:0-65535,udp:0-65535,icmp \
    --enable-logging \
    --source-ranges=0.0.0.0/0 
fi



exit

gcloud compute ssh ${ZONE}-vm \
--command 'sudo apt-get update -y ; sudo apt-get install git dnsutils curl -y '  \
--project ${PROJECT_ID} \
--zone ${ZONE}

