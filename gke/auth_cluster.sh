#!/bin/bash

# optional: use $1 to provide a cluster name 
# when no parameter is provided = project_id-cluster is being used 

export PROJECT_ID=`gcloud config get-value project`
if [ "${1}" == "" ] ; then
	export CLUSTER=`gcloud container clusters list --format="value(name)" --filter="name:${PROJECT_ID}-cluster"`
else
	export CLUSTER=$1
fi

export ZONE=`gcloud container clusters list --format="value(zone)" --filter="name:${CLUSTER}"`

gcloud config set project $PROJECT_ID
gcloud config set container/cluster $CLUSTER

echo "running : gcloud container clusters get-credentials $CLUSTER --zone $ZONE "
gcloud container clusters get-credentials $CLUSTER --zone $ZONE 
