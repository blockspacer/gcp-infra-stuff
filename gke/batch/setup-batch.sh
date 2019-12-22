#!/bin/bash

export PROJECT_ID=amiteinav-sandbox
export CLUSTER_NAME=amiteinav-sandbox-batch
export COMPUTE_REGION=europe-west1
export COMPUTE_ZONE=europe-west1-b

gcloud container clusters list | grep ${CLUSTER_NANE} > /dev/null 2>&1
if [ $? -ne 0 ] ; then

    gcloud beta container clusters create $CLUSTER_NAME \
    --project ${PROJECT_ID} \
    --region $COMPUTE_REGION \
    #--node-locations $COMPUTE_ZONE \
    --num-nodes 1 \
    --machine-type n1-standard-8 \
    --release-channel regular \
    --enable-stackdriver-kubernetes \
    --identity-namespace=${PROJECT_ID}.svc.id.goog \
    --enable-ip-alias
fi

