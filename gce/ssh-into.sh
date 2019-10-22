#!/bin/bash

#-p PROJECT_ID
#-h HOST_NAME
#-r -> INDICATE_THIS_ONLY_IF_YOU_WANT_TO_SEE_RUNNING_INSTANCES

# use this to list VMs in RUNNING state
./ssh-into.sh -r 

# use this to list VMs in RUNNING state from project XYZ
./ssh-into.sh -r -p XYZ

# use this to ssh into a VM by name
./ssh-into.sh -h hostname1


while getopts 'rp:h:' flag; do
    case "${flag}" in  
        p) p_flag="${OPTARG}" ;;
        h) host_name="${OPTARG}" ;;
        r) running_instances_only='true' ;;
        *) echo "no args provided" ;;
    esac
done 

if [ "$pflag" != "" ] ; then
    PROJECT_ID=$pflag
else
    PROJECT_ID=`gcloud config get-value project`
fi

#instances_list=`gcloud compute instances list --project ${PROJECT_ID}| grep -v NAME | awk '{print $1}'`
if [ "${running_instances_only}" == 'true' ] ; then
   gcloud compute instances list --format="csv(name,zone,status)" --filter="status:RUNNING" --project $PROJECT_ID | grep -v "name,zone,status" > /tmp/run$$
else
    gcloud compute instances list --format="csv(name,zone,status)" --project $PROJECT_ID | grep -v "name,zone,status" > /tmp/run$$
fi

if [ "${host_name}" == "" ] ; then

    echo "please chose an instance #"
    idx=1
    for line in `cat /tmp/run$$`  ; do
        instance=`echo $line | awk -F"," '{print $1}'`
        zone=`echo $line | awk -F"," '{print $2}'`
        status=`echo $line | awk -F"," '{print $3}'`
        echo "[${idx}] $instance ---> ($zone) state: $status"
        ((idx++))
    done

    read -p 'instance number: ' NUM
    zone=`sed "${NUM}q;d" /tmp/run$$ | awk -F"," '{print $2}'`
    instance_name=`sed "${NUM}q;d" /tmp/run$$ | awk -F"," '{print $1}'`

else

    count_dup=`cat /tmp/run$$ | awk -F"," '{print $1}' | grep ${host_name} | wc -l`
    if [ ${count_dup} -eq 1 ] ; then
        echo "server $host_name is valid"
        zone=`cat /tmp/run$$ | grep ${host_name} | awk -F"," '{print $2}'`
        instance_name=${host_name}
    else
        echo "server $host_name has $count_dup appearances in the list of VMs on ${PROJECT_ID} project"
    fi
fi

echo "gcloud compute ssh $instance_name --zone $zone --project ${PROJECT_ID}"
gcloud compute ssh $instance_name --zone $zone --project ${PROJECT_ID}