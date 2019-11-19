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
* Create two firewall rules to allow http rfc1918
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

