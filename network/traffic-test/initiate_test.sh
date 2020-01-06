#!/bin/bash

source params.sh

#from each machine run this:

curr_host=`hostname`
sizes="56 504 1492 4492 15492"

for target in `gcloud compute instances list | grep "\-nw-test-vm" | awk '{print $5}'` ; do

    for size in $sizes ; do
        sudo ping -i0.05  $target -c 100 -s $size \
        | grep -v "\---" | grep -v pipe | grep -v "\%" \
        | grep -v "PING" | uniq | awk '{print $1 "," $4",source_host,"$7}' \
        | sed "s/://g" | sed "s/time=//g" | sed "s/source_host/${curr_host}/g" | grep -v rtt | grep -v "\,,"
    done

done