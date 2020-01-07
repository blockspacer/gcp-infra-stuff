#!/bin/bash

source params.sh

for ZONE in `gcloud compute instances list --project ${PROJECT_ID} | grep nw-test-vm | awk '{print $2}'` ; do

    echo "Now eith ${ZONE}-nw-test-vm"

    gcloud compute ssh ${ZONE}-nw-test-vm \
    --command 'sudo apt-get update -y ; sudo apt-get install git dnsutils curl iperf iperf3 -y ; git clone https://github.com/amiteinav/gcp-infra-stuff.git'  \
    --project ${PROJECT_ID} \
    --zone ${ZONE} &

done