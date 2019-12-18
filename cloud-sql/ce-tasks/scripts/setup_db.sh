#!/bin/bash

source params.sh

MYSQLIP=$(gcloud sql instances describe ${INSTANCE_ID} --format="value(ipAddresses.ipAddress)")
mysql --host=$MYSQLIP --user=root --password-file $PASSWD  < ../sql/db_construct.sql