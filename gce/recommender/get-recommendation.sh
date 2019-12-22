#!/bin/bash

zones="asia-northeast1-b us-central1-a us-central1-b us-central1-f europe-west1-b us-east1-b us-west1-a"

PROJECT=`gcloud config get-value project`
RECOMMENDER=google.compute.instanceGroupManager.MachineTypeRecommender

for LOCATION in $zones ; do
    gcloud beta recommender recommendations list \
        --project=${PROJECT} \
        --location=${LOCATION} \
        --recommender=${RECOMMENDER} \
        --format=json
done

