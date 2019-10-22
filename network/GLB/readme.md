# Creating Cross-region Load Balancing

## Configuring instances
* Create the two instances in us-central1 region
```
gcloud compute instances create www-1 \
    --image-family debian-9 \
    --image-project debian-cloud \
    --zone us-central1-b \
    --tags http-tag \
    --metadata startup-script="#! /bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo '<!doctype html><html><body><h1>us-central1-b-www-1</h1></body></html>' | tee /var/www/html/index.html
      EOF"
```
```
gcloud compute instances create www-2 \
    --image-family debian-9 \
    --image-project debian-cloud \
    --zone us-central1-b \
    --tags http-tag \
    --metadata startup-script="#! /bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo '<!doctype html><html><body><h1>us-central1-b-www-2</h1></body></html>' | tee /var/www/html/index.html
      EOF"
```
* Create the two instances in europe-west1 region
```
gcloud compute instances create www-3 \
    --image-family debian-9 \
    --image-project debian-cloud \
    --zone europe-west1-b \
    --tags http-tag \
    --metadata startup-script="#! /bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo '<!doctype html><html><body><h1>europe-west1-b-www-3</h1></body></html>' | tee /var/www/html/index.html
      EOF"
```
```
gcloud compute instances create www-4 \
    --image-family debian-9 \
    --image-project debian-cloud \
    --zone europe-west1-b \
    --tags http-tag \
    --metadata startup-script="#! /bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo '<!doctype html><html><body><h1>europe-west1-b-www-4</h1></body></html>' | tee /var/www/html/index.html
      EOF" 
```
* Create the two instances in asia-northeast1 region
gcloud compute instances create www-5 \
    --image-family debian-9 \
    --image-project debian-cloud \
    --zone asia-northeast1-b \
    --tags http-tag \
    --metadata startup-script="#! /bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo '<!doctype html><html><body><h1>asia-northeast1-b-www-3</h1></body></html>' | tee /var/www/html/index.html
      EOF"
```
```
gcloud compute instances create www-6 \
    --image-family debian-9 \
    --image-project debian-cloud \
    --zone asia-northeast1-b \
    --tags http-tag \
    --metadata startup-script="#! /bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo '<!doctype html><html><body><h1>asia-northeast1-b-www-4</h1></body></html>' | tee /var/www/html/index.html
      EOF" 
```
* Create firewall rule
```
gcloud compute firewall-rules create www-firewall \
    --target-tags http-tag --allow tcp:80
```
## Configuring services for load balancing
* Create IPv4 global static external IP address for your load balancer.
```
gcloud compute addresses create lb-ip-cr \
    --ip-version=IPV4 \
    --global
```
* Create an instance group for each of your zones.
```
gcloud compute instance-groups unmanaged create us-resources-w --zone us-central1-b
gcloud compute instance-groups unmanaged create europe-resources-w --zone europe-west1-b
gcloud compute instance-groups unmanaged create asia-resources-w --zone asia-northeast1-b 

```
* Add the instances you created earlier to the instance groups
```
gcloud compute instance-groups unmanaged add-instances us-resources-w \
    --instances www-1,www-2 \
    --zone us-central1-b
gcloud compute instance-groups unmanaged add-instances europe-resources-w \
    --instances www-3,www-4 \
    --zone europe-west1-b
gcloud compute instance-groups unmanaged add-instances asia-resources-w \
    --instances www-5,www-6 \
    --zone asia-northeast1-b
```
* Create health check
```
gcloud compute health-checks create http http-basic-check
```
# Configuring the load balancing service
* For each instance group, define an HTTP service and map a port name to the relevant port
```
gcloud compute instance-groups unmanaged set-named-ports us-resources-w \
    --named-ports http:80 \
    --zone us-central1-b
gcloud compute instance-groups unmanaged set-named-ports europe-resources-w \
    --named-ports http:80 \
    --zone europe-west1-b
gcloud compute instance-groups unmanaged set-named-ports asia-resources-w \
    --named-ports http:80 \
    --zone asia-northeast1-b
```
* Create a backend service and specify its parameters.
```
gcloud compute backend-services create web-map-backend-service \
    --protocol HTTP \
    --health-checks http-basic-check \
    --global
```
* Add your instance groups as backends to the backend services
```
gcloud compute backend-services add-backend web-map-backend-service \
    --balancing-mode UTILIZATION \
    --max-utilization 0.8 \
    --capacity-scaler 1 \
    --instance-group us-resources-w \
    --instance-group-zone us-central1-b \
    --global
```
```
gcloud compute backend-services add-backend web-map-backend-service \
    --balancing-mode UTILIZATION \
    --max-utilization 0.8 \
    --capacity-scaler 1 \
    --instance-group europe-resources-w \
    --instance-group-zone europe-west1-b \
    --global
```
```
gcloud compute backend-services add-backend web-map-backend-service \
    --balancing-mode UTILIZATION \
    --max-utilization 0.8 \
    --capacity-scaler 1 \
    --instance-group asia-resources-w \
    --instance-group-zone asia-northeast1-b \
    --global
```
* Create a default URL map that directs all incoming requests to all your instances.
```
gcloud compute url-maps create web-map \
    --default-service web-map-backend-service
```
* Create a target HTTP proxy to route requests to your URL map.
```
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map
```
LB_IP_ADDRESS=`gcloud compute addresses list | grep "lb-ip-cr" | awk '{print $2}'`
gcloud compute forwarding-rules create http-cr-rule \
    --address ${LB_IP_ADDRESS} \
    --global \
    --target-http-proxy http-lb-proxy \
    --ports 80
```
* try the GLB
```
curl -s http://${LB_IP_ADDRESS}:80
```
## Shutting off HTTP access from everywhere but the load balancing service
* Once everything is working, modify your firewall rules so HTTP(S) traffic to your instances can only come from your load balancing service.
```
gcloud compute firewall-rules create allow-lb-and-healthcheck \
    --source-ranges 130.211.0.0/22,35.191.0.0/16 \
    --target-tags http-tag \
    --allow tcp:80
```
* Remove the rule that allows HTTP(S) traffic from other sources.
```
gcloud compute firewall-rules delete www-firewall
```
* Delete the access config for the instance. For NAME, put the name of the instance.
```
for host in `gcloud compute instances list | awk '{print $1}' | grep www-` ; do \
zone=`gcloud compute instances list | grep $host | awk '{print $2}'` ; \
echo "gcloud compute instances delete-access-config $host --zone $zone "; \
gcloud compute instances delete-access-config $host --zone $zone ; \
done
```
## Load testing - Create some traffic using locust
* Get the GLB IP address
```
LB_IP_ADDRESS=`gcloud compute addresses list | grep "lb-ip-cr" | awk '{print $2}'`
```
* Update the locust-files with the LB_IP_ADDRESS
  * locust-master-controller.yaml
  * locust-worker-controller.yaml
* Deploy the Locust master and worker nodes
```
kubectl apply -f locust-master-controller.yaml
kubectl apply -f locust-worker-controller.yaml
```
* Get the external IP for locust
```
EXTERNAL_IP=$(kubectl get svc locust-master -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
```
* Use a browser to start the test
```
http://${EXTERNAL_IP}:8089/
```
