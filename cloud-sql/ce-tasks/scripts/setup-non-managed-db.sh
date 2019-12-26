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

pass=`cat $SELFPASSWD`
MYSQLIP=`cat $IPFILE`

echo $MYSQLIP

mysql --host=$MYSQLIP --user=root --password=$pass BTS  < ${SQLDIR}/db_construct.sql

tables="ROLES SKILL_MAPPINGS SKILL_TYPES STATUS_TYPES TASK_TYPES USERS CUSTOMERS KNOWLEDGE_MAPPINGS QUEUES REQUESTS TASKS"

for table in $tables ; do
    if [ -f $CSVDIR/${table}.csv ] ; then
        echo "Now with table: $table"
        mysql --host=$MYSQLIP --user=root --password=$pass --execute="USE BTS ; LOAD DATA LOCAL INFILE '$CSVDIR/${table}.csv' INTO TABLE ${table} FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"' IGNORE 1 LINES ; SHOW WARNINGS"
    fi
done

bash query-db.sh ${MYSQLIP}


