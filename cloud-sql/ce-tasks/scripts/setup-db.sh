#!/bin/bash

git pull

source params.sh

gsutil -m cp gs://task-navigator-files/csv/* ${CSVDIR}

CE_TASK_TSV=${CSVDIR}/CE-tasks.tsv
ls ${CE_TASK_TSV} > /dev/null 2>&1
if [ $? -eq 0 ] ; then
    echo "populating information"
    python3 convert-csv-to-tables.py  -i ${CE_TASK_TSV}
fi

pass=`cat $PASSWD`
MYSQLIP=$(gcloud sql instances describe ${INSTANCE_ID} --format="value(ipAddresses.ipAddress)")

IP1=$(echo $MYSQLIP | awk -F";" '{print $1}')
IP2=$(echo $MYSQLIP | awk -F";" '{print $2}')

if [ $IP2 != "" ] ; then
    MYSQLIP=${IP2}
else
    MYSQLIP=${IP1}
fi

mysql --host=$MYSQLIP --user=root --password=$pass bts  < ${SQLDIR}/db_construct.sql

#table=REQUESTS
#mysql --execute="LOAD DATA LOCAL INFILE '$CSVDIR/$table.csv' INTO TABLE $table FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' IGNORE 1 LINES (listOfColumnNames); SHOW WARNINGS"
#mysql <options> -e "LOAD DATA LOCAL INFILE 'foo' INTO TABLE bar; SHOW WARNINGS"

tables="ROLES STATUS_TYPES TASK_TYPES CE_SKILLS QUEUES CUSTOMERS USERS TASKS TASK_OWNERS REQUESTS TASK_DETAILS_UPDATE" 
for table in $tables ; do
    if [ -f $CSVDIR/${table}.csv ] ; then
        echo "Now with table: $table"
        mysql --host=$MYSQLIP --user=root --password=$pass --execute="USE BTS ; LOAD DATA LOCAL INFILE '$CSVDIR/${table}.csv' INTO TABLE ${table} FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' IGNORE 1 LINES ; SHOW WARNINGS"
    fi
done


M0YKsspNAA_@pNAAsKpTot

#for table in $tables ; do
#    mysqlimport --local --host=$MYSQLIP --user=root \
#    --ignore-lines=1 --password=$pass --fields-terminated-by=',' \
#    BTS ${CSVDIR}/${table}.csv
#done

bash query-db.sh ${MYSQLIP}


