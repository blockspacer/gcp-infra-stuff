# HTTPS Load Balancing using NGINX and Google Compute Engine

## Obtain an SSL/TLS certificate

```
mkdir -p ssl-certs
cd ssl-certs
openssl genrsa -out example.key 2048
openssl rsa -in example.key -out example.key
openssl req -new -key example.key -out example.csr
openssl x509 -req -days 365 -in example.csr -signkey example.key -out example.crt
```

## Create and configure the load balancer backends
* Create the network
```
PROJECT=`gcloud config get-value project`
VPC=https-nginx
gcloud compute --project $PROJECT networks create $VPC --subnet-mode=auto
```
* Create the service account
```
PROJECT=`gcloud config get-value project`
SA=http-nginx-sa
gcloud iam service-accounts create $SA \
      --display-name "gce backend service account - https-nginx"
gcloud projects add-iam-policy-binding $PROJECT \
  --member serviceAccount:${SA}@${PROJECT}.iam.gserviceaccount.com \
  --role roles/editor
```
* Create three instances in a ZONE, tag them to automatically allow external HTTPS traffic through the firewall, install Apache Web Server on them, and enable Apache's SSL module 
```
VPC=https-nginx
ZONE=us-central1-a
SA=http-nginx-sa
NETWORK_TIER=PREMIUM
for i in {1..3}; \
  do \
    gcloud compute instances create www-backend-$i \
    --image-family debian-9 \
    --image-project debian-cloud \
    --tags "https-server" \
    --zone $ZONE \
    --network $VPC --subnet=$VPC \
    --network-tier=${NETWORK_TIER} \
    --service-account=${SA}@amiteinav-sandbox.iam.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --metadata startup-script="#! /bin/bash
    apt-get update
    apt-get install -y apache2
    /usr/sbin/a2ensite default-ssl
    /usr/sbin/a2enmod ssl
    service apache2 reload
    " ; \
  done
```
* Create a firewall rule:
```
VPC=https-nginx
gcloud compute firewall-rules \
create default-allow-https \
--network=$VPC \
--direction=INGRESS \
--priority=500 \
--action=ALLOW \
--rules=tcp:443 \
--source-ranges=0.0.0.0/0
```

* Obtain the external IP addresses of your instances. Run curl to verify that each instance is up and running
NOTE: The -k flag allows you to bypass the curl command's standard SSL/TLS certificate verification. This flag is necessary because, although the startup script configured Apache to receive HTTPS traffic on each instance, the instances do not yet have SSL certificates installed. the -I makes sure we only get the status code
```
VPC=https-nginx
ZONE=us-central1-a
SA=http-nginx-sa
NETWORK_TIER=PREMIUM
for i in {1..3}; \
  do \
    IP=`gcloud compute instances describe www-backend-$i | grep -i natIP | awk '{print $2}'` ; \
    echo "curl -I -k https://${IP}" ; \
    curl -I -k https://${IP} ; \
    done
```


