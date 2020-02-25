# HTTPS Load Balancing using NGINX and Google Compute Engine
## Obtain an SSL/TLS certificate
```
mkdir -p ssl_cert
cd ssl_cert
# Create a new private key (RSA-2048 and ECDSA P-256):
openssl genrsa -out example.key 2048
# Generate a signed certificate, a CSR (Certificate Signing Request). answer with '.' on everything if you want:
openssl req -new -key example.key -out example.csr
# Generate a self-signed certificate by running the following command (Self-signed certificates are not suitable for public sites)
openssl x509 -req -days 365 -in example.csr -signkey example.key -out example.crt
```

## Creating an SSL certificate resource from existing certificate files
* If you are configuring a load balancer with multiple SSL certificates, make sure that you create an SSL certificate resource for each certificate.
```
gcloud compute ssl-certificates create sslcert1 \
    --certificate ssl_cert/example.crt \
    --private-key ssl_cert/example.key
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
## Install your SSL certificates
* Upload ssl-certs directory to storage bucket
```
PROJECT_ID=`gcloud config get-value project`
BUCKET=${PROJECT_ID}-ssl-certs
REGION=us-central1
gsutil mb -l $REGION -p $PROJECT_ID -b on gs://${BUCKET}
gsutil cp -r ssl-certs gs://${BUCKET}
for i in {1..3}; \
  do \
  gcloud compute ssh www-backend-$i "ls" ; \
  done
```

