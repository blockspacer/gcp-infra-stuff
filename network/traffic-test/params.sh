export PROJECT_ID=`gcloud config get-value project` 
export PROJECT_NUMBER=`gcloud projects describe ${PROJECT_ID} --format="csv(projectNumber)" | tail -1`
echo "Project ID: ${PROJECT_ID}; Project number: ${PROJECT_NUMBER}"

export SERVICE_ACOUNT=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com
export MACHINE_TYPE=n1-standard-4

export NETWORK_NAME=network-latency-test-vpc