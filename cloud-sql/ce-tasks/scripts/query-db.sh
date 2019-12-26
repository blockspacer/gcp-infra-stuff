#!/bin/bash

source params.sh

pass=`cat $PASSWD`

MYSQLIP=$(gcloud sql instances describe ${INSTANCE_ID} --format="value(ipAddresses.ipAddress)")

IP1=$(echo $MYSQLIP | awk -F";" '{print $1}')
IP2=$(echo $MYSQLIP | awk -F";" '{print $2}')

if [ $IP2 != "" ] ; then
    MYSQLIP=${IP2}
else
    MYSQLIP=${IP1}
fi

mysql --host=$MYSQLIP --user=root --password=$pass bts  < ../sql/query_entire_db.sql


