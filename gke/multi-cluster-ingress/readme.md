# Setting up a multi-cluster Ingress
* original tutorial here > https://cloud.google.com/kubernetes-engine/docs/how-to/multi-cluster-ingress

## Creating the network
* Create the VPC and the subnets
```
PROJECT=`gcloud config get-value project`
VPC=multi-ingress-vpc 
gcloud compute --project $PROJECT networks create $VPC --subnet-mode=custom

gcloud beta compute --project $PROJECT networks subnets create us-central-multi-ingress-subnet \
--network $VPC \
--region=us-central1 \
--range=172.16.1.0/24 \
--enable-private-ip-google-access \
--enable-flow-logs

gcloud beta compute --project $PROJECT networks subnets create us-east1-multi-ingress-subnet \
--network $VPC \
--region=us-east1 \
--range=172.16.2.0/24 \
--enable-private-ip-google-access \
--enable-flow-logs
```
## Creating the service account
```
PROJECT=`gcloud config get-value project`
gcloud iam service-accounts create gke-mci-sa \
      --display-name "gke mci service account"

gcloud projects add-iam-policy-binding $PROJECT \
  --member serviceAccount:gke-mci-sa@${PROJECT}.iam.gserviceaccount.com \
  --role roles/editor
```

## Creating the clusters

### Create the clusters

* Create clusters in us-central and the us-east1 
```
VPC=multi-ingress-vpc 
SUBNET_CENTRAL=us-central-multi-ingress-subnet
SUBNET_EAST=us-east1-multi-ingress-subnet

gcloud container clusters create   \
    --zone=us-central1-a --enable-ip-alias --image-type="COS" --num-nodes="3" --network=$VPC --subnetwork=$SUBNET_CENTRAL \
    --enable-cloud-logging --enable-cloud-monitoring --enable-ip-alias \
    --service-account "gke-mci-sa@${PROJECT}.iam.gserviceaccount.com"  \
    --tags="allow-health-checks" \
    --enable-autoprovisioning --min-cpu=1 --max-cpu=16 --min-memory=1 --max-memory 64 mci-central-cluster

gcloud container clusters create   \
    --zone=us-east1-b --enable-ip-alias --image-type="COS" --num-nodes="3" --network=$VPC --subnetwork=$SUBNET_EAST \
    --enable-cloud-logging --enable-cloud-monitoring --enable-ip-alias \
    --service-account "gke-mci-sa@${PROJECT}.iam.gserviceaccount.com"  \
    --tags="allow-health-checks" \
    --enable-autoprovisioning --min-cpu=1 --max-cpu=16 --min-memory=1 --max-memory 64 mci-east-cluster

```
* Get Clusters credentials
KUBECONFIG=clusters.yaml gcloud container clusters \
    get-credentials mci-east-cluster --zone=us-east1-b

KUBECONFIG=clusters.yaml gcloud container clusters \
    get-credentials mci-central-cluster --zone=us-central1-a

```

### Delpoy the sample application
* Deploy the application along with its NodePort Service in each of the two clusters. 
* You can get the cluster contexts from kubectl config get-contexts and iterate through all the clusters to deploy the application manifests. 
* This could be accomplished by running the following loop:
```
for ctx in $(kubectl config get-contexts -o=name --kubeconfig clusters.yaml); do
  kubectl --kubeconfig clusters.yaml --context="${ctx}" create -f manifests/
done
```
* Check that the pods are set up
```
for ctx in $(kubectl config get-contexts -o=name --kubeconfig clusters.yaml); do echo "${ctx}:" ;  kubectl --kubeconfig clusters.yaml --context="${ctx}" get pods | grep zoneprinter; done
```

### Reserve a static IP address
```
ZP_KUBEMCI_IP="zp-kubemci-ip"
gcloud compute addresses create --global "${ZP_KUBEMCI_IP}" --network-tier=PREMIUM
```

### Make sure FW rules are there
```
* Create the FW
VPC=`gcloud container clusters describe east-cluster --zone us-east1-b --format="value(network)" `
gcloud compute firewall-rules create fw-allow-health-checks-${VPC} \
    --network ${VPC} \
    --action ALLOW \
    --direction INGRESS \
    --source-ranges 35.191.0.0/16,130.211.0.0/22 \
    --target-tags allow-health-checks \
    --rules tcp \
    --priority 300
```

### Deploy the multi-cluster Ingress wtih kubecmi
```
export PROJECT=`gcloud config get-value project`
gcloud compute project-info update --default-network-tier PREMIUM
kubemci create zone-printer \
    --ingress=ingress/ingress.yaml \
    --gcp-project=$PROJECT \
    --kubeconfig=clusters.yaml
```

* View the multi-cluster Ingress status
```
kubemci get-status zone-printer --gcp-project=$PROJECT
```

* Test the multi-cluster Ingress
```
IP=`kubemci list | grep zone-printer | awk '{print $2}'`
curl http://$IP 
```

