#!/bin/bash

source params.sh

MYSQLIP=$(gcloud sql instances describe ${INSTANCE_ID} --format="value(ipAddresses.ipAddress)")
mysql --host=$MYSQLIP --user=root --password --verbose < recreate_db.sql