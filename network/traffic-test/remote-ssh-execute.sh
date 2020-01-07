#!/bin/bash

source params.sh

# $1 is the command to run across all servers 
# Example:
# $0 "cd ~/gcp-infra-stuff/network/traffic-test; git pull ; bash ping_test.sh"

if [ "${1}" != "" ] ; then
    command=$1
else
    command="hostname; sudo apt-get update -y ; sudo apt-get install git dnsutils curl iperf iperf3 inetutils-traceroute -y ; git clone https://github.com/amiteinav/gcp-infra-stuff.git"
fi

for curr_ZONE in `gcloud compute instances list --project ${PROJECT_ID} | grep nw-test-vm | awk '{print $2}'` ; do

    echo "Dispaatching at ${curr_ZONE}-nw-test-vm"
    
    echo "gcloud compute ssh ${curr_ZONE}-nw-test-vm --command '${command}' --project ${PROJECT_ID} --zone ${curr_ZONE} &"
    
    gcloud compute ssh ${curr_ZONE}-nw-test-vm \
    --command '${command}'  \
    --project ${PROJECT_ID} \
    --zone ${curr_ZONE} &

    

done