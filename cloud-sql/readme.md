# Loading Data into Google Cloud SQL
Import data from CSV text files into Cloud SQL and then carry out some basic data analysis using simple queries

## Clone the Data Science on GCP Repository
```
git clone https://github.com/GoogleCloudPlatform/data-science-on-gcp/
cd data-science-on-gcp/03_sqlstudio
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export BUCKET=${PROJECT_ID}-ml
```

## Create a Cloud SQL instance (takes 5 minutes)


* Option 1: Setup the instance (public IP)
```
export REGION=europe-west1
export INSTANCE_ID=flights
gcloud sql instances create $INSTANCE_ID \
    --tier=db-n1-standard-1 --activation-policy=ALWAYS --region $REGION
```

* Option 2: Setup instance with private IP
```
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export INSTANCE_ID=flights-private
export REGION=europe-west1
export VPC_NETWORK_NAME=privatenet
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

* Install MySQL client
```
sudo apt-get install mysql-client-core-5.7
```
* Connect to the Cloud SQL instance
```
MYSQLIP=$(gcloud sql instances describe  $INSTANCE_ID --format="value(ipAddresses.ipAddress)")
mysql --host=$MYSQLIP --user=root \
      --password --verbose < create_table.sql
```
* Import CSV files into Cloud SQL
```
CSV_PREFIX=flights.csv
DB=bts
export INSTANCE_ID=flights-private
MYSQLIP=$(gcloud sql instances describe ${INSTANCE_ID} --format="value(ipAddresses.ipAddress)")
mysqlimport --local --host=$MYSQLIP --user=root --ignore-lines=1 --fields-terminated-by=',' --password ${DB} ${CSV_PREFIX}-*
``` 

