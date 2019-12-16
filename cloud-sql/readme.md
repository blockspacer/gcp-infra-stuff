# Loading Data into Google Cloud SQL
Import data from CSV text files into Cloud SQL and then carry out some basic data analysis using simple queries

## Preperation
* Clone the Data Science on GCP Repository
```
git clone https://github.com/GoogleCloudPlatform/data-science-on-gcp/
cd data-science-on-gcp/03_sqlstudio
```
* Setup environment variables
```
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export BUCKET=${PROJECT_ID}-ml
export REGION=europe-west1
export INSTANCE_ID=flights-private
export VPC_NETWORK_NAME=privatenet
```

## Create a Cloud SQL instance 

* Option 1: Setup an instance with a public IP
```
export INSTANCE_ID=flights-public
gcloud sql instances create $INSTANCE_ID \
    --tier=db-n1-standard-1 --activation-policy=ALWAYS --region $REGION
```

* Option 2: Setup instance with private IP
```
time gcloud --project=${PROJECT_ID} beta sql instances create ${INSTANCE_ID} \
       --network=${VPC_NETWORK_NAME} \
       --no-assign-ip \
       --region ${REGION}
```

* Setup the password
```
pass=`openssl rand -base64 32 | head -c 16`
echo $pass3 > ${INSTANCE_ID}_password.txt
gcloud sql users set-password root --host % --instance $INSTANCE_ID \
 --password $pass3
```
## Connect to the Cloud SQL MySQL instance
* Install MySQL client (if needed)
```
sudo apt-get install mysql-client-core-5.7
```
* Connect to the Cloud SQL instance
```
MYSQLIP=$(gcloud sql instances describe  $INSTANCE_ID --format="value(ipAddresses.ipAddress)")
mysql --host=$MYSQLIP --user=root \
      --password --verbose < create_table.sql
```

# Add data to Cloud SQL instance
* clone the git with all the CSV files
```
git clone  https://github.com/amiteinav/gcp-infra-stuff.git
cd gcp-infra-stuff/cloud-sql/csv
```
* Import CSV files into Cloud SQL
```
CSV_PREFIX=flights.csv
DB=bts
MYSQLIP=$(gcloud sql instances describe ${INSTANCE_ID} --format="value(ipAddresses.ipAddress)")
mysqlimport --local --host=$MYSQLIP --user=root --ignore-lines=1 --fields-terminated-by=',' --password ${DB} ${CSV_PREFIX}-*
``` 
* upload all data into Cloud SQL
```
mysqlimport --local --host=$MYSQLIP --user=root --password --ignore-lines=1 \
--fields-terminated-by=',' bts flights.csv-*

mysqlimport --local --host=$MYSQLIP --user=root --password \
--ignore-lines=1 --fields-terminated-by=',' bts *.csv
```

## Scroll around MySQL
* Connect to the mysql command line interface:
```
mysql --host=$MYSQLIP --user=root  --password
```
* In the mysql command line interface check the import by entering the following commands
```
use bts;
describe flights;
```
* Query the flights table
```
select DISTINCT(FL_DATE) from flights
```
* Query the flights table for unique carrier identifiers:
```
select DISTINCT(CARRIER) from flights;
```
* use environment variables to test different values for arrival and departure delay thresholds
```
SET @ARR_DELAY_THRESH = 15;
SET @DEP_DELAY_THRESH = 10;
# Correct - true negative
select count(dest) from flights where arr_delay < @ARR_DELAY_THRESH and dep_delay < @DEP_DELAY_THRESH;
# False negative
select count(dest) from flights where arr_delay >= @ARR_DELAY_THRESH and dep_delay < @DEP_DELAY_THRESH;
# False positive
select count(dest) from flights where arr_delay < @ARR_DELAY_THRESH and dep_delay >= @DEP_DELAY_THRESH;
# True positive
select count(dest) from flights where arr_delay >= @ARR_DELAY_THRESH and dep_delay >= @DEP_DELAY_THRESH;
```
* Exit the MySQL interactive console
```
exit
```
