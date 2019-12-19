#!/bin/bash

source params.sh

cat $PASSWD

MYSQLIP=$(gcloud sql instances describe ${INSTANCE_ID} --format="value(ipAddresses.ipAddress)")
mysql --host=$MYSQLIP --user=root --password --verbose  < ../sql/db_construct.sql

mysqlimport --local --host=$MYSQLIP --user=root --ignore-lines=1 --fields-terminated-by=',' bts roles.csv users.csv


