#!/bin/bash

source params.sh


echo "Starting with network testing setup script"


instances_to_delete=`gcloud compute instances list | grep "\-nw-test-vm" | awk '{print $1}' > /dev/null 2>&1` 
if [ "${instances_to_delete}" != "" ] ; then

    for instnace in ${instances_to_delete} ; do
        zone=`echo $instance | sed "s/-nw-test-vm//g"`
        gcloud compute instances delete $instance --quiet --delete-disks=all --zone $zone
    fi

fi