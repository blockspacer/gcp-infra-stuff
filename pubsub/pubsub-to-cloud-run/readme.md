# Using Pub/Sub with Cloud Run tutorial

based on https://cloud.google.com/run/docs/tutorials/pubsub

This tutorial shows how to write, deploy, and call a Cloud Run service from a Pub/Sub push subscription.

## Setting up
```
gcloud services enable run.googleapis.com
PROJECT_ID=`gcloud config get-value project`
```

## Creating a pub/sub topic
* The sample service is triggered by messages published to a Pub/Sub topic, so you'll need to create a topic in Pub/Sub.
```
TOPIC=myRunTopic
gcloud pubsub topics create $TOPIC
```
## Retrieving the code sample
```
git clone https://github.com/amiteinav/gcp-infra-stuff.git
cd gcp-infra-stuff/pubsub/pubsub-to-cloud-run/nodejs
```

## Shipping the code

* Build, pusblish and deploy the app
```
PROJECT_ID=`gcloud config get-value project`
IMAGE=pubsub-run
REGION=us-central1
docker build . -t gcr.io/${PROJECT_ID}/${IMAGE} 
docker push gcr.io/${PROJECT_ID}/${IMAGE} 
gcloud beta run deploy pubsub-run-tutorial \
    --image gcr.io/${PROJECT_ID}/${IMAGE} \
    --no-allow-unauthenticated \
    --platform=managed \
    --region=${REGION}
```

## Integrating with Pub/Sub
* Enable Pub/Sub to create authentication tokens in your project
```
PROJECT_NUMBER=`gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)"`
REGION=us-central1

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
     --member=serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com \
     --role=roles/iam.serviceAccountTokenCreator

gcloud iam service-accounts create cloud-run-pubsub-invoker \
     --display-name "Cloud Run Pub/Sub Invoker"

gcloud run services add-iam-policy-binding pubsub-run-tutorial \
   --member=serviceAccount:cloud-run-pubsub-invoker@${PROJECT_ID}.iam.gserviceaccount.com \
   --role=roles/run.invoker \
   --platform=managed \
   --region=${REGION}

SERVICE_URL=`gcloud beta run services describe pubsub-run-tutorial --platform=managed --region=${REGION} | grep https`
gcloud pubsub subscriptions create myRunSubscription --topic ${TOPIC} \
   --push-endpoint=${SERVICE_URL}/ \
   --push-auth-service-account=cloud-run-pubsub-invoker@${PROJECT_ID}.iam.gserviceaccount.com
```

## Test this with high volumes
* Use cloud shceduler jobs for "bomarding" the cloud run 
```
TOPIC=myRunTopic
for i in {1..20} ; do \
gcloud scheduler jobs create pubsub publisher-job-$i \
 --schedule="* * * * *" \
 --topic=${TOPIC} --message-body="job-$i:Hello!" ; \
gcloud scheduler jobs run publisher-job-$i & \
done
```
* Check the last messages from the logging
```
gcloud logging read "resource.type=cloud_run_revision \
AND resource.labels.service_name=pubsub-run-tutorial \
AND resource.labels.location=$REGION" \
--limit=30 \
--format="table[box](timestamp,textPayload)"
 ```
 * Delete the Cloud Scheduler jobs
 ```
 for i in {1..20} ; do \
 gcloud scheduler jobs delete publisher-job-$i --quiet & \
 done
 ```