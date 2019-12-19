#!/bin/bash

source params.sh

pass=`cat $PASSWD`

echo $pass

MYSQLIP=$(gcloud sql instances describe ${INSTANCE_ID} --format="value(ipAddresses.ipAddress)")
mysql --host=$MYSQLIP --user=root --password=$pass bts  < ../sql/db_construct.sql

mysqlimport --local --host=$MYSQLIP --user=root --ignore-lines=1 --password=$pass --fields-terminated-by=',' bts ../csv/roles.csv ../csv/users.csv


