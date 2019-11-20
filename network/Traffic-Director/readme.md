# Traffic Director lab

* Set project to work on
```
PROJECT=amiteinav-sandbox
gcloud config set project $PROJECT
```
* Create a VPC named vpc-demo
```
gcloud compute networks create vpc-demo --subnet-mode custom
```
* Create 3 subnets within vpc-demo VPC 
```
gcloud compute networks subnets create vpc-demo-subnet1 --network vpc-demo \
    --range 10.1.1.0/24 --region us-central1
gcloud compute networks subnets create vpc-demo-subnet2 --network vpc-demo \
    --range 10.2.1.0/24 --region us-central1
gcloud compute networks subnets create vpc-demo-subnet3 --network vpc-demo \
    --range 10.3.1.0/24 --region us-east1
```
* Create firewall rules to allow http rfc1918 and health checks
```
gcloud compute firewall-rules create vpc-demo-allow-http-rfc1918 \
--direction=INGRESS --priority=1000 --network=vpc-demo --action=ALLOW \
--rules=tcp:80,tcp:8000 --source-ranges=10.0.0.0/8,192.168.0.0/16
gcloud compute firewall-rules create vpc-demo-allow-health-checks \
--direction=INGRESS --priority=1000 --network=vpc-demo --action=ALLOW \
--rules=tcp:80,tcp:8000 --source-ranges=130.211.0.0/22,35.191.0.0/16
```
* Enalbe the Traffic Director API and the GKE API
```
gcloud services enable trafficdirector.googleapis.com --async
gcloud services enable container.googleapis.com --async 
```
* Create GKE Cluster in us-central1
```
gcloud beta container clusters create central-cluster \
--subnetwork=vpc-demo-subnet1 \
--network=vpc-demo \
--scopes=https://www.googleapis.com/auth/cloud-platform \
--enable-ip-alias \
--cluster-ipv4-cidr 10.1.8.0/21 \
--services-ipv4-cidr 10.1.16.0/24 \
--zone=us-central1-a
```
* Create GKE Cluster in us-east1.
```
gcloud beta container clusters create east-cluster \
--subnetwork=vpc-demo-subnet3 \
--network=vpc-demo \
--scopes=https://www.googleapis.com/auth/cloud-platform \
--enable-ip-alias \
--cluster-ipv4-cidr 10.3.8.0/21 \
--services-ipv4-cidr 10.3.16.0/24 \
--zone=us-east1-b
```
* Get credentials for the central-cluster and save the current-context as a variable.
```
gcloud container clusters get-credentials central-cluster \
--zone us-central1-a
CENTRAL=`kubectl config current-context`
```
* Get credentials for the east-cluster and save the current-context as a variable.
```
gcloud container clusters get-credentials east-cluster \
--zone us-east1-b
EAST=`kubectl config current-context`
```
* Make sure to have the current project in a variable
```
PROJECT=`gcloud config get-value project`
```

* Get the yaml file (also on this repo)
```
wget https://storage.googleapis.com/cloudnet-19-td-lab/app1.yaml
```

* Deply app1 on the central-cluster and east-cluster
```
for cluster in $CENTRAL $EAST ; do echo $cluster ; \
kubectl apply -f app1.yaml --cluster=$cluster ; \
done
```
* Retrieve the busybox deployment manifest (Also on this repo)
```
wget https://storage.googleapis.com/cloudnet-19-td-lab/busybox.yaml
```
* Deploy busybox on the central-cluster and east-cluster
```
for cluster in $CENTRAL $EAST ; do echo $cluster ; \
kubectl apply -f busybox.yaml --cluster=$cluster ; \
done
```
* Review that the pods are deployed
```
for cluster in $CENTRAL $EAST ; do echo $cluster ; \
kubectl get pods --cluster=$cluster ; \
done
```
* Not a must: install weavscope on the clusters
```
for cluster in $CENTRAL $EAST ; do echo $cluster ; \
kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')" \
--cluster=$cluster ; \
done
```
* Note a must: From your laptop run this to view the 'contexed' cluster
```
kubectl port-forward -n weave \
"$(kubectl get -n weave pod \
--selector=weave-scope-component=app -o jsonpath='{.items..metadata.name}')" 4040
```
* View current Network Endpoint Groups (NEGs). You should see two NEGs, each of size 2.
```
gcloud compute network-endpoint-groups list
```
* Save each NEG as a variable, as we will need to refer to them when creating the backend-service:
```
CENTRAL_APP1_NEG=$(gcloud beta compute network-endpoint-groups list --filter=us-central1 --format="value(name)")
EAST_APP1_NEG=$(gcloud beta compute network-endpoint-groups list --filter=us-east1 --format="value(name)")
```
* Configure a basic HTTP health check that will be used for all backends:
```
gcloud compute health-checks create http td-gke-health-check \
--use-serving-port
```
* The health checks configured in each backend service are sourced from 130.211.0.0/22 and 35.191.0.0/16 - Make sure all FW-rules are set
```
cd gcp-infra-stuff/network
source restore-settings.sh
```

* Configure the backend service and associate the http health-check configured previously. 
* Note the backend service is global and uses load-balancing-scheme of INTERNAL_SELF_MANAGED
```
gcloud compute backend-services create td-gke-service \
    --global \
    --health-checks td-gke-health-check \
    --load-balancing-scheme INTERNAL_SELF_MANAGED
```
* Addinh backend NEGs to the backend service. Like the HTTP/S load balancer, regional backends consisting of MIGs or NEGs can be added to the backend-service.
* Adding app1 Central NEG to the backend service:
```
gcloud compute backend-services add-backend td-gke-service \
    --global \
    --network-endpoint-group ${CENTRAL_APP1_NEG} \
    --network-endpoint-group-zone us-central1-a \
    --balancing-mode RATE \
    --max-rate-per-endpoint 5
```
* Add app1 East NEG to the backend service.
```
gcloud compute backend-services add-backend td-gke-service \
    --global \
    --network-endpoint-group ${EAST_APP1_NEG} \
    --network-endpoint-group-zone us-east1-b \
    --balancing-mode RATE \
    --max-rate-per-endpoint 5
```
* Create the URL map to route traffic to the backend service:
```
gcloud compute url-maps create td-gke-url-map \
--default-service td-gke-service 
```
* Create the target HTTP proxy. This is a logical config pointer that represents the envoy proxies distributed throughout the service mesh
```
gcloud compute target-http-proxies create td-gke-proxy \
    --url-map td-gke-url-map
```
* Create the forwarding rule with the service IP address. We are using an arbitrary IP of 10.99.1.1 in this example.
```
gcloud compute forwarding-rules create td-gke-forwarding-rule \
    --global \
    --target-http-proxy td-gke-proxy --ports 80 \
    --address 10.99.1.1 \
    --network vpc-demo \
    --load-balancing-scheme INTERNAL_SELF_MANAGED
```

* Make sure to restore all settings that might have been lost (FW-rules and Variables)
```
cd gcp-infra-stuff/network/Traffic-Director
source restore-settings.sh
```

* Test reachability to our service VIP (10.99.1.1) by using our busybox client in our central-cluster.
```
kubectl exec -it $(kubectl get po -l run=client -o=jsonpath='{.items[0].metadata.name}' \
--cluster=$CENTRAL) --cluster=$CENTRAL -c busybox -- /bin/sh -c 'wget -q -O - 10.99.1.1'; echo
```

* Test reachability to our service VIP (10.99.1.1) by using our busybox client in our east-cluster
```
kubectl exec -it $(kubectl get po -l run=client -o=jsonpath='{.items[0].metadata.name}' --cluster=$EAST) --cluster=$EAST -c busybox -- /bin/sh -c 'wget -q -O - 10.99.1.1'; echo
```
* Delete the app1 deployment in the central-cluster
```
kubectl delete deployment app1 --cluster=$CENTRAL
```
* Test reachability to our service VIP (10.99.1.1) by using our busybox client in our central-cluster.
```
kubectl exec -it $(kubectl get po -l run=client -o=jsonpath='{.items[0].metadata.name}' \
--cluster=$CENTRAL) --cluster=$CENTRAL -c busybox -- /bin/sh -c 'wget -q -O - 10.99.1.1'; echo
```
* Once the health check fails on the local central pods, note that you are now seamlessly directed to the east-cluster pods outside of the local region. This is very powerful as Traffic Director provides global proximity aware load balancing out of the box.
*  re-deploy App1 back to the central-cluster
```
kubectl apply -f app1.yaml --cluster=$CENTRAL
```
* Create a new backend service for app2
```
kubectl apply -f app2.yaml --cluster=$CENTRAL
gcloud compute backend-services create td-gke-service-v2 \
    --global \
    --health-checks td-gke-health-check \
    --load-balancing-scheme INTERNAL_SELF_MANAGED

CENTRAL_APP2_NEG=$(gcloud beta compute network-endpoint-groups list --format="value(name,zone.scope())" | grep central | grep -v $CENTRAL_APP1_NEG | awk '{print $1}')
```

* Add app2 NEG in central-cluster to new backend service
```
gcloud compute backend-services add-backend td-gke-service-v2 \
    --global \
    --network-endpoint-group=${CENTRAL_APP2_NEG} \
    --network-endpoint-group-zone us-central1-a \
    --balancing-mode RATE \
    --max-rate-per-endpoint 5
```
* export command to get the URL map config
```
gcloud beta compute url-maps export td-gke-url-map \
--destination=url-map-config.yaml \
--global
```

* retrieve a copy of a traffic-splitting url-map config and update it with the current project's details
```
wget -q -O - https://storage.googleapis.com/cloudnet-19-td-lab/td-gke-urlmap.yaml | envsubst > url-map-config-split.yaml
```
* import command to update the URL map and implement the changes
```
gcloud beta compute url-maps import td-gke-url-map \
    --source ./url-map-config-split.yaml \
    --global -q
```