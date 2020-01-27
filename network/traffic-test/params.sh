export PROJECT_ID=`gcloud config get-value project` 
export PROJECT_NUMBER=`gcloud projects describe ${PROJECT_ID} --format="csv(projectNumber)" | tail -1`
echo "Project ID: ${PROJECT_ID}; Project number: ${PROJECT_NUMBER}"

export SERVICE_ACCOUNT=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com
export MACHINE_TYPE=n1-standard-4

export NETWORK_NAME=network-latency-test-vpc


https://storage.googleapis.com/amiteinav-pics/mando/mando1.mkv
https://storage.googleapis.com/amiteinav-pics/mando/mando2.mkv
https://storage.googleapis.com/amiteinav-pics/mando/mando3.mkv
https://storage.googleapis.com/amiteinav-pics/mando/mando4.mkv
https://storage.googleapis.com/amiteinav-pics/mando/mando5.mkv
https://storage.googleapis.com/amiteinav-pics/mando/mando6.mkv
https://storage.googleapis.com/amiteinav-pics/mando/mando7.mkv
https://storage.googleapis.com/amiteinav-pics/mando/mando8.mkv
https://storage.googleapis.com/amiteinav-pics/mando/OUATIH.mp4