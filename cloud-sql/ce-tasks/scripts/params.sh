#!/bin/bash

export PROJECT_ID=amiteinav-sandbox
export REGION=europe-west1
export INSTANCE_ID=task-navigator-mysql-1
export SELF_MANAGED_INSTANCE_ID=self_managed_mysql
export VPC_NETWORK_NAME=privatenet
export EU_WST=privatenet-europe-west1
export EMAIL=amiteinav@google.com
export MGMT_VM=mgmt-instance-1
export SERVICE_ACCOUNT=mgmt-instance-sa@task-navigator.iam.gserviceaccount.com
export PASSWD=${INSTANCE_ID}_password.txt
export IPFILE=${INSTANCE_ID}_ip.txt
export CSVDIR=../csv/
export SQLDIR=../sql/
export USERNAME=ce-tasks-admin

