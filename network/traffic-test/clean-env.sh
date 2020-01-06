#!/bin/bash

source params.sh

echo "Cleaning network testing setup "


instances_to_delete=`gcloud compute instances list | grep "\-nw-test-vm" | awk '{print $1}'` 
if [ "${instances_to_delete}" != "" ] ; then

    for instance in ${instances_to_delete} ; do
        zone=`echo $instance | sed "s/-nw-test-vm//g"`
        echo "gcloud compute instances delete $instance --quiet --delete-disks=all --zone $zone"
        gcloud compute instances delete $instance --quiet --delete-disks=all --zone $zone  &
    done
fi

gcloud compute instances list | grep "\-nw-test-vm" | awk '{print $1}'