#!/bin/bash

source params.sh

for curr_ZONE in `gcloud compute instances list --project ${PROJECT_ID} | grep nw-test-vm | awk '{print $2}'` ; do

    echo "Now with ${curr_ZONE}-nw-test-vm"
    gcloud compute ssh ${curr_ZONE}-nw-test-vm \
    --command 'hostname; sudo apt-get update -y ; sudo apt-get install git dnsutils curl iperf iperf3 -y ; git clone https://github.com/amiteinav/gcp-infra-stuff.git'  \
    --project ${PROJECT_ID} \
    --zone ${curr_ZONE} &

done