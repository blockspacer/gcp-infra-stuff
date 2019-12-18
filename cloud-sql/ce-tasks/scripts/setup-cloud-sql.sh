#!/bin/bash

source params.sh

echo "Setting project to ${PROJECT_ID}"
gcloud config set project ${PROJECT_ID}

gcloud compute --project=task-navigator networks list | grep ${VPC_NETWORK_NAME} > /dev/null 2>&1
if [ $? -ne 0 ] ; then
    echo "Creating network ${VPC_NETWORK_NAME}"
    gcloud compute --project=task-navigator networks create ${VPC_NETWORK_NAME} --subnet-mode=custom
else
    echo "network ${VPC_NETWORK_NAME} already exists"
fi

gcloud beta compute --project=${PROJECT_ID} networks subnets list | grep $EU_WST > /dev/null 2>&1
if [ $? -ne 0 ] ; then  
    echo "Creating subnet $EU_WST"
    gcloud beta compute --project=${PROJECT_ID} networks subnets \
    create $EU_WST --network=${VPC_NETWORK_NAME} \
    --region=$REGION \
    --range=172.20.1.0/24 \
    --enable-private-ip-google-access \
    --enable-flow-logs
else
    echo "subnet $EU_WST already exists"
fi

gcloud beta compute --project=${PROJECT_ID} firewall-rules list  \
 --filter=network:${VPC_NETWORK_NAME} | grep allow-iap-ssh  > /dev/null 2>&1

if [ $? -ne 0 ] ; then
    gcloud beta compute --project=${PROJECT_ID} \
    firewall-rules create allow-iap-ssh --direction=INGRESS --priority=900 \
    --network=${VPC_NETWORK_NAME} --action=ALLOW --rules=all \
    --source-ranges=35.235.240.0/20 --enable-logging    
fi

gcloud projects get-iam-policy ${PROJECT_ID} | grep -B1 -A1 "${EMAIL}" 

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member=user:${EMAIL} \
--role=roles/iap.tunnelResourceAccessor

#gcloud compute instances list | grep ${MGMT_VM} >  /dev/null 2>&1
echo "skipping creation of mgmt instancex"
if [ $? -ne 0 ] ; then
    echo "Creating instance"
    gcloud beta compute --project=$PROJECT_ID instances create ${MGMT_VM} \
    --zone=europe-west1-b --machine-type=n1-standard-1 --subnet=privatenet-europe-west1 \
    --no-address \
    --maintenance-policy=MIGRATE \
    --service-account=${SERVICE_ACCOUNT} \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --image=debian-9-drawfork-v20191004 \
    --image-project=eip-images \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --reservation-affinity=any
fi

# gcloud beta compute ssh mgmt-instance-1 --zone=europe-west1-b

gcloud services enable sqladmin.googleapis.com --project=${PROJECT_ID}
gcloud services enable servicenetworking.googleapis.com --project=${PROJECT_ID}

gcloud --project=${PROJECT_ID} beta sql instances list | grep ${INSTANCE_ID}  /dev/null 2>&1
if [ $? -ne 0 ] ; then
    echo "Creating ${INSTANCE_ID} - should take 5 minutes"
    time gcloud --project=${PROJECT_ID} beta sql instances create ${INSTANCE_ID} \
        --network=${VPC_NETWORK_NAME} \
        --region $REGION \
        --no-assign-ip
fi

pass=`openssl rand -base64 32 | head -c 16`
echo $pass > ${PASSWD}
gcloud sql users set-password root --host % --instance $INSTANCE_ID  --password $pass