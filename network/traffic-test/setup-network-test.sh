#!/bin/bash

source params.sh

#PREEMPTIBLE=--preemptible
REGIONS=`gcloud compute regions list | grep -v NAME | awk '{print $1}' | uniq`

STD_REGIONS="asia-east1 asia-east2 asia-northeast1 asia-southeast1 australia-southeast1 europe-north1 europe-west1 europe-west2 europe-west3 europe-west4 europe-west6 northamerica-northeast1 southamerica-east1 us-central1 us-east1 us-east4 us-west1 us-west2"

echo "Starting with network testing setup script"

echo "Enabling service compute.googleapis.com"
gcloud services enable --project $PROJECT_ID compute.googleapis.com 

gcloud compute --project=${PROJECT_ID} networks list | grep ${NETWORK_NAME} > /dev/null 2>&1
if [ $? -ne 0 ] ; then
  echo "Creating network ${NETWORK_NAME} and automated subnets"
  gcloud compute --project=${PROJECT_ID} networks create ${NETWORK_NAME} --subnet-mode=auto
fi

for REGION in ${REGIONS} ; do
  echo "gcloud compute networks subnets update network-latency-test-vpc --region=${REGION} --enable-flow-logs"
  gcloud compute networks subnets update network-latency-test-vpc --region=${REGION} --enable-flow-logs &
done

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
    --boot-disk-type=pd-ssd &
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

# Get the list of VMs
gcloud compute instances list --project charged-polymer-221319 | grep nw-test-vm | awk '{print $1"\t"$2"\t"$5}'

asia-east1-c-nw-test-vm         asia-east1-c            35.206.195.255
asia-east2-c-nw-test-vm         asia-east2-c            35.215.146.175
asia-northeast1-a-nw-test-vm    asia-northeast1-a       35.213.78.176
asia-south1-a-nw-test-vm        asia-south1-a           35.207.228.12
asia-southeast1-c-nw-test-vm    asia-southeast1-c       35.213.185.175
australia-southeast1-a-nw-test-vm       australia-southeast1-a  35.213.194.248
europe-north1-c-nw-test-vm      europe-north1-c         35.217.23.55
europe-west1-c-nw-test-vm       europe-west1-c          35.210.165.243
europe-west2-a-nw-test-vm       europe-west2-a          35.214.50.51
europe-west3-b-nw-test-vm       europe-west3-b          35.207.97.3
europe-west4-c-nw-test-vm       europe-west4-c          35.214.207.52
europe-west6-c-nw-test-vm       europe-west6-c          35.216.161.71
northamerica-northeast1-c-nw-test-vm    northamerica-northeast1-c       35.215.10.206
southamerica-east1-a-nw-test-vm southamerica-east1-a    35.215.204.126
us-central1-b-nw-test-vm        us-central1-b           35.208.15.103
us-east1-d-nw-test-vm           us-east1-d              35.211.152.32
us-east4-a-nw-test-vm           us-east4-a              35.212.19.223
us-west1-a-nw-test-vm           us-west1-a              35.212.178.130
us-west2-c-nw-test-vm            us-west2-c              35.215.70.239

# connect to a VM
gcloud compute ssh --project charged-polymer-221319  europe-west1-c-nw-test-vm --zone europe-west1-c


gcloud compute ssh ${ZONE}-vm \
--command 'sudo apt-get update -y ; sudo apt-get install git dnsutils curl iperf iperf3 -y '  \
--project ${PROJECT_ID} \
--zone ${ZONE}

#https://geo.ipify.org/subscriptions
IPFYKEY=at_Ywq2sYAwk7n4boBSqy5NjmpDgiBRB
curl "https://geo.ipify.org/api/v1?apiKey=${IPFYKEY}&ipAddress=104.132.36.65"