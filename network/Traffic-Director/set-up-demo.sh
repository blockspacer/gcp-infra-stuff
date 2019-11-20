#!/bin/bash -x

PROJECT=`gcloud config get-value project`

gcloud services enable trafficdirector.googleapis.com --async
gcloud services enable container.googleapis.com --async 

gcloud compute networks create vpc-demo --subnet-mode custom

gcloud compute networks subnets create vpc-demo-subnet1 --network vpc-demo \
    --range 10.1.1.0/24 --region us-central1 &

gcloud compute networks subnets create vpc-demo-subnet2 --network vpc-demo \
    --range 10.2.1.0/24 --region us-central1 &

gcloud compute networks subnets create vpc-demo-subnet3 --network vpc-demo \
    --range 10.3.1.0/24 --region us-east1 &

gcloud compute firewall-rules create vpc-demo-allow-http-rfc1918 \
--direction=INGRESS --priority=1000 --network=vpc-demo --action=ALLOW \
--rules=tcp:80,tcp:8000 --source-ranges=10.0.0.0/8,192.168.0.0/16 &

gcloud compute firewall-rules create vpc-demo-allow-health-checks \
--direction=INGRESS --priority=1000 --network=vpc-demo --action=ALLOW \
--rules=tcp:80,tcp:8000 --source-ranges=130.211.0.0/22,35.191.0.0/16 &

gcloud beta container clusters create central-cluster \
--subnetwork=vpc-demo-subnet1 \
--network=vpc-demo \
--scopes=https://www.googleapis.com/auth/cloud-platform \
--enable-ip-alias \
--cluster-ipv4-cidr 10.1.8.0/21 \
--services-ipv4-cidr 10.1.16.0/24 \
--zone=us-central1-a &

gcloud beta container clusters create east-cluster \
--subnetwork=vpc-demo-subnet3 \
--network=vpc-demo \
--scopes=https://www.googleapis.com/auth/cloud-platform \
--enable-ip-alias \
--cluster-ipv4-cidr 10.3.8.0/21 \
--services-ipv4-cidr 10.3.16.0/24 \
--zone=us-east1-b 

gcloud container clusters get-credentials central-cluster \
--zone us-central1-a
CENTRAL=`kubectl config current-context`

gcloud container clusters get-credentials east-cluster \
--zone us-east1-b
EAST=`kubectl config current-context`

