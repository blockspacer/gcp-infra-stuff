#!/bin/bash

source params.sh

pass=`cat $PASSWD`

if [ $1 != "" ] ; then
    MYSQLIP=$1
else
    MYSQLIP=$(gcloud sql instances describe ${INSTANCE_ID} --format="value(ipAddresses.ipAddress)")
fi

mysql --host=$MYSQLIP --user=root --password=$pass bts  < ../sql/query_entire_db.sql


