#!/bin/bash

export PROJECT=amiteinav-sandbox
gcloud config set project $PROJECT


count=`gcloud compute firewall-rules list --filter vpc-demo-allow --format="(name,network,disabled)" | wc -l`
if [ $count -ne 3 ] ; then
    gcloud compute firewall-rules create vpc-demo-allow-http-rfc1918 \
    --direction=INGRESS --priority=1000 --network=vpc-demo --action=ALLOW \
    --rules=tcp:80,tcp:8000 --source-ranges=10.0.0.0/8,192.168.0.0/16 &
    gcloud compute firewall-rules create vpc-demo-allow-health-checks \
    --direction=INGRESS --priority=1000 --network=vpc-demo --action=ALLOW \
    --rules=tcp:80,tcp:8000 --source-ranges=130.211.0.0/22,35.191.0.0/16 &
fi

gcloud container clusters get-credentials central-cluster \
--zone us-central1-a
export CENTRAL=`kubectl config current-context`

gcloud container clusters get-credentials east-cluster \
--zone us-east1-b
export EAST=`kubectl config current-context`

export CENTRAL_APP1_NEG=$(gcloud beta compute network-endpoint-groups list --filter=us-central1 --format="value(name)")
export EAST_APP1_NEG=$(gcloud beta compute network-endpoint-groups list --filter=us-east1 --format="value(name)")