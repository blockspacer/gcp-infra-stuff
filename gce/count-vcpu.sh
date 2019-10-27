#!/bin/sh

PROJECT=`gcloud config get-value project`
WORK_FILE=/tmp/workfile$$
MACHINE_TYPES_FILE=/tmp/machine_types$$

echo "Getting Instances list"
gcloud compute instances list \
--filter="(machine_type:n1 OR machine_type:custom) AND status:running" \
 --format='value(machine_type)'  \
 | awk -F"/" '{print $9","$11}' \
 > $WORK_FILE

echo "Getting specs"
gcloud compute machine-types list \
--format='value(name,CPUS,MEMORY_GB)' | \
sort -n | \
uniq | \
awk '{print $1","$2","$3}' | \
sed "s/.00//g" | \
sed "s/.25//g" | \
sed "s/.75//g" | \
sed "s/.50//g" > $MACHINE_TYPES_FILE

echo "Calculating total"
total_cpus=0
total_mem=0
for line in `cat $WORK_FILE` ; do
    curr_server=`echo $line | awk -F"," '{print $2","}'`

    echo $curr_server | grep custom > /dev/null 2>&1
    if [ $? -ne 0 ] ; then
        cpus=`grep $curr_server $MACHINE_TYPES_FILE | awk -F"," '{print $2}'`
        mem=`grep $curr_server  $MACHINE_TYPES_FILE | awk -F"," '{print $3}'`
    else
        cpus=`echo $curr_server | awk -F"-" '{print $2}' | sed 's/,//g'`
        mem=`echo $curr_server | awk -F"-" '{print $3}' | sed 's/,//g'`
    fi
    echo "$curr_server,$cpus,$mem"
    ((total_cpus=total_cpus+cpus))
    ((total_mem=total_mem+mem))
done

echo "Total cpus: $total_cpus"
echo "Total mem: $total_mem"