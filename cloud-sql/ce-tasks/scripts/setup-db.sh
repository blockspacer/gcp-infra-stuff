#!/bin/bash

git pull

source params.sh

gsutil -m cp gs://task-navigator-files/csv/* ../csv/

CE_TASK_TSV=../csv/CE-tasks.tsv
ls ${CE_TASK_TSV} > /dev/null 2>&1
if [ $? -eq 0 ] ; then
    echo "populating information"
    python3 convert-csv-to-tables.py  -i ${CE_TASK_TSV}
fi

pass=`cat $PASSWD`
MYSQLIP=$(gcloud sql instances describe ${INSTANCE_ID} --format="value(ipAddresses.ipAddress)")

mysql --host=$MYSQLIP --user=root --password=$pass bts  < ../sql/db_construct.sql

mysqlimport --local --host=$MYSQLIP --user=root \
--ignore-lines=1 --password=$pass --fields-terminated-by=',' \
BTS \
#../csv/*.csv
../csv/REQUESTS.csv

bash query-db.sh


