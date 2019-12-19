#!/bin/bash

source params.sh

pass=`cat $PASSWD`

MYSQLIP=$(gcloud sql instances describe ${INSTANCE_ID} --format="value(ipAddresses.ipAddress)")

mysql --host=$MYSQLIP --user=root --password=$pass bts  < ../sql/query_entire_db.sql


