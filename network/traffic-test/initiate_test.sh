#!/bin/bash

source params.sh

#from each machine run this:

curr_host=`hostname`
sizes="56 504 1492 4492 15492"

gcloud compute instances list | grep "\-nw-test-vm" | awk '{print $1" "$5}' > /tmp/file$$

for target in `cat /tmp/file$$ | awk '{print $2}'` ; do

    target_host=`grep $target /tmp/file$$ | awk '{print $1}'`
    if [ "${target_host}" != "${curr_host}"]

        for size in $sizes ; do
            sudo ping -i0.05  $target -c 100 -s $size \
            | grep -v "\---" | grep -v pipe | grep -v "\%" \
            | grep -v "PING" | uniq | awk '{print  ",target_host,source_host,"$1","$7}' \
            | sed "s/://g" | sed "s/time=//g" | sed "s/source_host/${curr_host}/g" | grep -v rtt | grep -v "\,," | sed "s/target_host/${target_host}/g"
        done

    fi

done