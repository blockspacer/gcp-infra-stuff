#!/bin/bash -x

VPC=default
gcloud beta compute --project=`gcloud config get-value project` \
firewall-rules create \
allow-rdp \
--network=$VPC \
--direction=INGRESS \
--priority=900 \
--network=default \
--action=ALLOW \
--rules=tcp:3389 \
--source-ranges=0.0.0.0/0 \
--enable-logging
