# Setting up a multi-cluster Ingress
https://cloud.google.com/kubernetes-engine/docs/how-to/multi-cluster-ingress

## Creating the clusters

### Create the clusters

* Create a cluster in us-central and get its credentials
```
gcloud container clusters create \
    --cluster-version=1.9 \
    --zone=us-central1-a \
    central-cluster &
```
* Create a cluster in eu-east and get its credentials
```
gcloud container clusters create \
    --cluster-version=1.9 \
    --zone=us-east1-b \
    east-cluster &
```
* Get Clusters credentials
KUBECONFIG=clusters.yaml gcloud container clusters \
    get-credentials east-cluster --zone=us-east1-b

KUBECONFIG=clusters.yaml gcloud container clusters \
    get-credentials central-cluster --zone=us-central1-a

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